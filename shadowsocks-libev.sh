#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    shadowsocks-libev.sh
# Revision:    1.0(1)
# Date:        2017/09/01
# Author:      Kane
# Email:       waveworkshop@outlook.com
# Website:     www.wavengine.com
# Description: shadowsocks-libev server install for Debian / Ubuntu
# Notes:       run "./shadowsocks-libev.sh 2>&1 | tee shadowsocks-libev.log"
# -------------------------------------------------------------------------------
# Copyright:   2017 (c) Wave WorkShop
# License:     GPL
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# you should have received a copy of the GNU General Public License
# along with this program (or with Nagios);
#
# Credits go to Ethan Galstad for coding Nagios
# If any changes are made to this script, please mail me a copy of the changes
# -------------------------------------------------------------------------------

clear
echo
echo "#############################################################"
echo "# shadowsocks-libev server install for Debian / Ubuntu      #"
echo "# Thanks: @clowwindy <https://twitter.com/clowwindy>        #"
echo "# Author: Wave WorkShop <waveworkshop@outlook.com>          #"
echo "# Github: https://github.com/shadowsocks/shadowsocks-libev  #"
echo "#############################################################"
echo

# Fonts color
RED="\033[31;1m"
GREEN="\033[32;1m"
YELLOW="\033[33;1m"
BLUE="\033[34;1m"
PURPLE="\033[35;1m"
CYAN="\033[36;1m"
FONT="\033[0m"

# Info messages
FAIL="${RED}[FAIL]${FONT}"
DONE="${GREEN}[DONE]${FONT}"
ERROR="${RED}[ERROR]${FONT}"
WARNING="${YELLOW}[WARNING]${FONT}"
CANCEL="${CYAN}[CANCEL]${FONT}"

# Current folder
cur_dir=`pwd`

# Make sure only root can run our script
rootness(){
    if [[ $EUID -ne 0 ]]; then
        echo -e "${FAIL} must be run as root user." 1>&2
        exit 1
    fi
}

# Check system
check_sys(){
    local checkType=$1
    local value=$2
    local release=''
    # Support Debian / Ubuntu only
    if [[ -s /etc/redhat-release ]]; then
        clear
        echo -e "${ERROR} CentOS is not supported. Please reinstall to Debian / Ubuntu and try again."
        exit 1
    fi
    # Determine Debian or Ubuntu
    if cat /etc/issue | grep -Eqi "debian"; then
        release="debian"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        release="ubuntu"
    elif cat /proc/version | grep -Eqi "debian"; then
        release="debian"
    elif cat /proc/version | grep -Eqi "ubuntu"; then
        release="ubuntu"
    fi

    if [[ ${checkType} == "sysRelease" ]]; then
        if [ "$value" == "$release" ]; then
            return 0
        else
            return 1
        fi
    fi
}

# Get Linux version
linux_version(){
    grep -oE  "[0-9.]+" /etc/issue
}

# Get Kernel version
kernel_version(){
    uname -r |grep -Eo '[0-9].[0-9]+'|sed -n '1,1p'
}

# Debian or Ubuntu version support
support(){
    # bc command check
    command -v bc >/dev/null 2>&1 || { clear; echo >&2 "The bc command is not installed. Aborting."; exit 1; }
    # Linux
    local max=`linux_version`
    if check_sys sysRelease debian; then
        local min=7
        if [ `echo "$max > $min" | bc` -eq 1 ]; then
            echo "Current: Debian `linux_version`"
        else
            clear
            echo -e "${ERROR}Not supported Debian 7 or older version, please update and try again."
            exit 1
        fi
    elif check_sys sysRelease ubuntu; then
        local min=14
        local mid=`echo ${max%.*}`
        local lat=`echo ${mid%.*}`
        if [ `echo "$lat > $min" | bc` -eq 1 ]; then
            echo "Current: Ubuntu `linux_version`"
        else
            clear
            echo -e "${ERROR}Not supported Ubnutu 14 or older version, please update and try again."
            exit 1
        fi

    fi
}

# Get public IP address
get_ip(){
    local IP=$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipinfo.io/ip )
    [ ! -z ${IP} ] && echo ${IP} || echo
}

get_char(){
    SAVEDSTTY=`stty -g`
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty $SAVEDSTTY
}

# Prepare installation
pre_install(){
    # Set shadowsocks config password
    echo "Please input password for shadowsocks:"
    read -p "(Default: material):" shadowsocks_passwd
    [ -z "${shadowsocks_passwd}" ] && shadowsocks_passwd="material"
    echo
    echo "---------------------------"
    echo "password = ${shadowsocks_passwd}"
    echo "---------------------------"
    echo
    # Set shadowsocks encryption method
    echo "Please select encryption method for shadowsocks:"
    echo "01. rc4-md5"
    echo "02. aes-128-ctr"
    echo "03. aes-192-ctr"
    echo "04. aes-256-ctr"
    echo "05. aes-128-cfb"
    echo "06. aes-192-cfb"
    echo "07. aes-256-cfb"
    echo "08. chacha20"
    echo "09. chacha20-ietf"
    echo "10. aes-128-gcm"
    echo "11. aes-192-gcm"
    echo "12. aes-256-gcm (recommend)"
    echo "13. chacha20-ietf-poly1305"
    read -p "(Default: aes-256-gcm):" number
    case "$number" in
      1)
        shadowsocks_method="rc4-md5"
        ;;
      2)
        shadowsocks_method="aes-128-ctr"
        ;;
      3)
        shadowsocks_method="aes-192-ctr"
        ;;
      4)
        shadowsocks_method="aes-256-ctr"
        ;;
      5)
        shadowsocks_method="aes-128-cfb"
        ;;
      6)
        shadowsocks_method="aes-192-cfb"
        ;;
      7)
        shadowsocks_method="aes-256-cfb"
        ;;
      8)
        shadowsocks_method="chacha20"
        ;;
      9)
        shadowsocks_method="chacha20-ietf"
        ;;
      10)
        shadowsocks_method="aes-128-gcm"
        ;;
      11)
        shadowsocks_method="aes-192-gcm"
        ;;
      12)
        shadowsocks_method="aes-256-gcm"
        ;;
      13)
        shadowsocks_method="chacha20-ietf-poly1305"
        ;;
      *)
        shadowsocks_method="aes-256-gcm"
        ;;
    esac
    echo
    echo "---------------------------"
    echo "encryption method = ${shadowsocks_method}"
    echo "---------------------------"
    echo
    # Set shadowsocks config port
    while true
    do
    echo -e "Please input port for shadowsocks [1-65535]:"
    read -p "(Default: 8388):" shadowsocks_port
    [ -z "$shadowsocks_port" ] && shadowsocks_port="8388"
    expr ${shadowsocks_port} + 0 &>/dev/null
    if [ $? -eq 0 ]; then
        if [ ${shadowsocks_port} -ge 1 ] && [ ${shadowsocks_port} -le 65535 ]; then
            echo
            echo "---------------------------"
            echo "port = ${shadowsocks_port}"
            echo "---------------------------"
            echo
            break
        else
            echo "Input error, please input correct number!"
        fi
    else
        echo "Input error, please input correct number!"
    fi
    done
    # Prepare finish
    echo
    echo -e "Press any key to start...or Press ${RED}Ctrl+C${FONT} to cancel"
    char=`get_char`
    # Install necessary dependencies
    apt-get -y update
    sudo apt-get -y install --no-install-recommends gettext build-essential autoconf libtool libpcre3-dev asciidoc xmlto libev-dev libc-ares-dev automake 
    sudo apt-get -y install --no-install-recommends build-essential autoconf libtool libssl-dev libpcre3-dev libudns-dev libev-dev asciidoc xmlto automake
    cd ${cur_dir}
}

# Download files
download_files(){
    # Download libsodium file
    if ! wget --no-check-certificate -O libsodium-latest.tar.gz https://download.libsodium.org/libsodium/releases/LATEST.tar.gz; then
        echo "Failed to download libsodium file!"
        exit 1
    fi
    # Download MbedTLS file
    local MBEDTLS_VER=2.6.0
    if ! wget --no-check-certificate https://tls.mbed.org/download/mbedtls-$MBEDTLS_VER-gpl.tgz; then
        echo "Failed to download MbedTLS file!"
        exit 1
    fi
    # Download Shadowsocks init script
    if ! wget --no-check-certificate https://raw.githubusercontent.com/wavengine/shadowsocks-install/master/shadowsocks-libev -O /etc/init.d/shadowsocks-libev; then
        echo "Failed to download shadowsocks chkconfig file!"
        exit 1
    fi
}

# Config shadowsocks
write_conf(){
    cat > /etc/shadowsocks-libev.json<<-EOF
{
    "server":"0.0.0.0",
    "server_port":"${shadowsocks_port}",
    "local_port":1080,
    "password":"${shadowsocks_passwd}",
    "timeout":"300",
    "method":"${shadowsocks_method}",
    "plugin":"obfs-server",
    "plugin_opts":"obfs=http;fast-open"
}
EOF
}

# Install shadowsocks
install(){
    # Install libsodium
    tar zxf libsodium-latest.tar.gz
    cd libsodium-1.*
    ./configure && make && make install
    if [ $? -ne 0 ]; then
        echo "libsodium install failed!"
        cleanup
        exit 1
    fi
    echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf
    sudo ldconfig
    # Install MbedTLS
    cd ${cur_dir}
    tar xvf mbedtls-$MBEDTLS_VER-gpl.tgz
    cd mbedtls-$MBEDTLS_VER
    make SHARED=1 CFLAGS=-fPIC
    sudo make DESTDIR=/usr install
    if [ $? -ne 0 ]; then
        echo "MbedTLS install failed!"
        cleanup
        exit 1
    fi
    sudo ldconfig
    # Git clone shadowsocks
    cd ${cur_dir}
    git clone https://github.com/shadowsocks/shadowsocks-libev.git
    cd shadowsocks-libev
    git submodule update --init --recursive
    # Install shadowsocks
    ./autogen.sh && ./configure && make
    sudo make install
    # Install simple-obfs
    cd ${cur_dir}
    git clone https://github.com/shadowsocks/simple-obfs.git
    cd simple-obfs
    git submodule update --init --recursive
    ./autogen.sh && ./configure && make
    sudo make install
    # Complate install
    if [ -f /usr/local/bin/ss-server ]; then
        chmod +x /etc/init.d/shadowsocks-libev
        update-rc.d -f shadowsocks-libev defaults
        /etc/init.d/shadowsocks-libev start
    else
        echo
        echo -e "${FAIL} shadowsocks-libev install failed! please email waveworkshop@outlook.com to contact me."
        cleanup
        exit 1
    fi

    clear
    echo -e "#--------------------------------------#"
    echo -e "# ${CYAN}Linux version${FONT}:  `linux_version`"
    echo -e "# ${CYAN}Kernel version${FONT}:  `kernel_version`"
    echo -e "#-----------------------------------------------------#"
    echo -e "# ${CYAN}Server${FONT}: ${RED} $(get_ip) ${FONT}"
    echo -e "# ${CYAN}Remote Port${FONT}: ${RED} ${shadowsocks_port} ${FONT}"
    echo -e "# ${CYAN}Local Port${FONT}: ${RED} 1080 ${FONT}"
    echo -e "# ${CYAN}Password${FONT}: ${RED} ${shadowsocks_passwd} ${FONT}"
    echo -e "# ${CYAN}Encrypt Method${FONT}: ${RED} ${shadowsocks_method} ${FONT}"
    echo -e "# ${CYAN}Plugin${FONT}: ${RED} obfs${FONT}"
    echo -e "#-----------------------------------------------------#"
    echo
}

# Cleanup install files
cleanup(){
    cd ${cur_dir}
    rm -rf shadowsocks-libev simple-obfs libsodium-latest.tar.gz libsodium-1.* mbedtls-$MBEDTLS_VER-gpl.tgz mbedtls-$MBEDTLS_VER
}

# Optimize the shadowsocks server on Linux
optimize_linux(){
    # Backup Linux default
    cp /etc/security/limits.conf /etc/security/limits.conf.bak
    cp /etc/sysctl.conf /etc/sysctl.conf.bak
    # First of all, make sure your Linux kernel is 3.7 or later please."
    local min=3.11
    local max=`kernel_version`
    if [ `echo "$max > $min" | bc` -eq 1 ]
    then
        # To handle thousands of concurrent TCP connections, we should increase the limit of file descriptors opened.
        echo "* soft nofile 51200" >> /etc/security/limits.conf
        echo "* hard nofile 51200" >> /etc/security/limits.conf
    else
        exit 1
    fi
    local bbr=4.8
    if [ `echo "$max > $bbr" | bc` -eq 1 ]
    then
        # Tune the kernel parameters (Use Google BBR)
        echo "fs.file-max = 51200" >> /etc/sysctl.conf
        echo " " >> /etc/sysctl.conf
        echo "net.core.rmem_max = 67108864" >> /etc/sysctl.conf
        echo "net.core.wmem_max = 67108864" >> /etc/sysctl.conf
        echo "net.core.netdev_max_backlog = 250000" >> /etc/sysctl.conf
        echo "net.core.somaxconn = 4096" >> /etc/sysctl.conf
        echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
        echo " " >> /etc/sysctl.conf
        echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_tw_recycle = 0" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_fin_timeout = 30" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_keepalive_time = 1200" >> /etc/sysctl.conf
        echo "net.ipv4.ip_local_port_range = 10000 65000" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_max_syn_backlog = 8192" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_max_tw_buckets = 5000" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_mem = 25600 51200 102400" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_rmem = 4096 87380 67108864" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_wmem = 4096 65536 67108864" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_mtu_probing = 1" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
        # reload the config at runtime.
        sysctl -p 1> /dev/null
    else
        # Tune the kernel parameters (Use hybla)
        echo "fs.file-max = 51200" >> /etc/sysctl.conf
        echo " " >> /etc/sysctl.conf
        echo "net.core.rmem_max = 67108864" >> /etc/sysctl.conf
        echo "net.core.wmem_max = 67108864" >> /etc/sysctl.conf
        echo "net.core.netdev_max_backlog = 250000" >> /etc/sysctl.conf
        echo "net.core.somaxconn = 4096" >> /etc/sysctl.conf
        echo " " >> /etc/sysctl.conf
        echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_tw_recycle = 0" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_fin_timeout = 30" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_keepalive_time = 1200" >> /etc/sysctl.conf
        echo "net.ipv4.ip_local_port_range = 10000 65000" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_max_syn_backlog = 8192" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_max_tw_buckets = 5000" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_mem = 25600 51200 102400" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_rmem = 4096 87380 67108864" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_wmem = 4096 65536 67108864" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_mtu_probing = 1" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control = hybla" >> /etc/sysctl.conf
        # reload the config at runtime.
        sysctl -p 1> /dev/null
    fi
}

# Uninstall shadowsocks
uninstall_shadowsocks(){
    echo -e "${WARNING} Are you sure uninstall shadowsocks-libev? (y/n) "
    read -p "(Default: n):" answer
    [ -z ${answer} ] && answer="n"
    if [ "${answer}" == "y" ] || [ "${answer}" == "Y" ]; then
        ps -ef | grep -v grep | grep -i "ss-server" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            /etc/init.d/shadowsocks-libev stop
        fi
        # Remove system config
        update-rc.d -f shadowsocks-libev remove
        
        # Delete config file
        rm -f /etc/shadowsocks-libev.json
        rm -f /var/run/shadowsocks-libev.pid
        rm -f /etc/init.d/shadowsocks-libev
        # Restore Linux 
        mv /etc/security/limits.conf.bak /etc/security/limits.conf
        mv /etc/sysctl.conf.bak /etc/sysctl.conf
        echo "shadowsocks uninstall success! "
    else
        echo
        echo -e "${CANCEL} Cancelled, nothing to do. "
        echo
    fi
}

# Install shadowsocks-libev
install_shadowsocks(){
    rootness
    support
    pre_install
    download_files
    write_conf
    install
    cleanup
    optimize_linux
}

# Initialization step
action=$1
[ -z $1 ] && action=install
case "$action" in
    install|uninstall)
        ${action}_shadowsocks
        ;;
    about)
        clear
        echo -e "Copyright ${BLUE}(C)${FONT} 2016-2017 by ${RED}Wave WorkShop${FONT} <waveworkshop@outlook.com>"
        ;; 
    *)
        clear
        echo "Arguments error! [${action}]"
        echo "Usage: `basename $0` [install|uninstall|about]"
        ;;
esac
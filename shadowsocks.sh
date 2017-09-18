#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    shadowsocks.sh
# Revision:    2.0(3)
# Date:        2017/09/17
# Author:      Kane
# Email:       waveworkshop@outlook.com
# Website:     www.wavengine.com
# Description: shadowsocks python server install for Debian / Ubuntu
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
echo "# shadowsocks python server install for Debian / Ubuntu     #"
echo "# Thanks: @clowwindy <https://twitter.com/clowwindy>        #"
echo "# Author: Wave WorkShop <waveworkshop@outlook.com>          #"
echo "# Github: https://github.com/shadowsocks/shadowsocks        #"
echo "#############################################################"
echo

# Echo color
RED="\033[31;1m"
GREEN="\033[32;1m"
YELLOW="\033[33;1m"
BLUE="\033[34;1m"
PURPLE="\033[35;1m"
CYAN="\033[36;1m"
PLAIN="\033[0m"

# Info messages
FAIL="${RED}[FAIL]${PLAIN}"
DONE="${GREEN}[DONE]${PLAIN}"
ERROR="${RED}[ERROR]${PLAIN}"
WARNING="${YELLOW}[WARNING]${PLAIN}"
CANCEL="${CYAN}[CANCEL]${PLAIN}"

# Current folder
cur_dir=`pwd`

# Make sure only root can run our script
rootness(){
    if [[ $EUID -ne 0 ]]; then
        echo -e "${WARNING} MUST RUN AS ${RED}ROOT${PLAIN} USER!"
        exit 1
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

# Configure shadowsocks setting
first_set_config(){
    # Set shadowsocks config password
    echo "Please input password for shadowsocks:"
    echo "default: material"
    read shadowsocks_passwd
    [ -z "${shadowsocks_passwd}" ] && shadowsocks_passwd="material"
    echo
    echo "---------------------------"
    echo "password = ${shadowsocks_passwd}"
    echo "---------------------------"
    echo
    # Set shadowsocks encryption method
    echo "Please select encryption method for shadowsocks:"
    echo "1. rc4-md5                  10. camellia-128-cfb"
    echo "2. aes-128-cfb              11. camellia-192-cfb"
    echo "3. aes-192-cfb              12. camellia-256-cfb"
    echo "4. aes-256-cfb              13. aes-128-gcm"
    echo "5. aes-128-ctr              14. aes-192-gcm"
    echo "6. aes-192-ctr              15. aes-256-gcm"
    echo "7. aes-256-ctr              16. sodium:aes-256-gcm (recommend)"
    echo "8. chacha20                 17. chacha20-ietf-poly1305"
    echo "9. chacha20-ietf            18. xchacha20-ietf-poly1305"
    echo "default: sodium:aes-256-gcm"
    read number
    case "$number" in
        1)
            shadowsocks_method="rc4-md5"
            ;;
        2)
            shadowsocks_method="aes-128-cfb"
            ;;
        3)
            shadowsocks_method="aes-192-cfb"
            ;;
        4)
            shadowsocks_method="aes-256-cfb"
            ;;
        5)
            shadowsocks_method="aes-128-ctr"
            ;;
        6)
            shadowsocks_method="aes-192-ctr"
            ;;
        7)
            shadowsocks_method="aes-256-ctr"
            ;;
        8)
            shadowsocks_method="chacha20"
            ;;
        9)
            shadowsocks_method="chacha20-ietf"
            ;;
        10)
            shadowsocks_method="camellia-128-cfb"
            ;;
        11)
            shadowsocks_method="camellia-192-cfb"
            ;;
        12)
            shadowsocks_method="camellia-256-cfb"
            ;;
        13)
            shadowsocks_method="aes-128-gcm"
            ;;
        14)
            shadowsocks_method="aes-192-gcm"
            ;;
        15)
            shadowsocks_method="aes-256-gcm"
            ;;
        16)
            shadowsocks_method="sodium:aes-256-gcm"
            ;;
        17)
            shadowsocks_method="chacha20-ietf-poly1305"
            ;;
        18)
            shadowsocks_method="xchacha20-ietf-poly1305"
            ;;
        *)
            shadowsocks_method="sodium:aes-256-gcm"
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
    echo "Please input port for shadowsocks [1-65535]:"
    echo "default: 8388"
    read shadowsocks_port
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
    # Set TCP Fast Open for shadowsocks
    echo "Do you want to use TCP-FastOpen for shadowsocks? (y/n)"
    echo "default: y"
    read tfo
    case "$tfo" in
            Y|y)
                shadowsocks_fastopen="true"
                ;;
            N|n)
                shadowsocks_fastopen="false"
                ;;
            *)
                shadowsocks_fastopen="true"
                ;;
    esac
    echo
    echo "---------------------------"
    echo "fast_open = ${shadowsocks_fastopen}"
    echo "---------------------------"
    echo
    # optimize kernel
    echo "Do you want to optimize kernel for shadowsocks? (y/n)"
    echo "default: y"
    read opzcore
    case "$opzcore" in
            Y|y)
                OPTIMIZE_MARK=1
                ;;
            N|n)
                OPTIMIZE_MARK=0
                ;;
            *)
                OPTIMIZE_MARK=1
                ;;
    esac
    # Prepare finish
    echo
    echo -e "Press any key to start...or Press ${RED}Ctrl+C${PLAIN} to cancel"
    char=`get_char`
    # Install necessary dependencies
    apt-get -y update
    apt-get -y install python python-dev python-pip python-setuptools python-m2crypto curl wget unzip gcc swig automake make perl cpio build-essential
    apt-get -y install screen bc sudo
    # Return Home
    cd ${cur_dir}
}

# Download files
second_download_files(){
    # Download libsodium file
    if ! wget --no-check-certificate -O libsodium-latest.tar.gz https://download.libsodium.org/libsodium/releases/LATEST.tar.gz; then
        echo "Failed to download libsodium file!"
        exit 1
    fi
    # Download Shadowsocks file
    if ! wget --no-check-certificate -O shadowsocks-master.zip https://github.com/shadowsocks/shadowsocks/archive/master.zip; then
        echo "Failed to download shadowsocks python file!"
        exit 1
    fi
    # Download Shadowsocks init script
    if ! wget --no-check-certificate https://raw.githubusercontent.com/wavengine/shadowsocks-install/master/shadowsocks -O /etc/init.d/shadowsocks; then
        echo "Failed to download shadowsocks chkconfig file!"
        exit 1
    fi
}

# Write shadowsocks config
third_write_config(){
    cat > /etc/shadowsocks.json<<-EOF
{
    "server":"0.0.0.0",
    "server_port":${shadowsocks_port},
    "password":"${shadowsocks_passwd}",
    "timeout":300,
    "method":"${shadowsocks_method}",
    "fast_open":${shadowsocks_fastopen}
}
EOF
}

# Install shadowsocks
fourth_install(){
    # Install libsodium
    tar zxvf libsodium-latest.tar.gz
    pushd libsodium-1.*
    ./configure --prefix=/usr && make && make install
    if [ $? -ne 0 ]; then
        echo "libsodium install failed!"
        fifth_cleanup
        exit 1
    fi
    echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf
    ldconfig
    popd
    # Install shadowsocks
    cd ${cur_dir}
    unzip -q shadowsocks-master.zip
    if [ $? -ne 0 ]; then
        echo -e "${FAIL} unzip shadowsocks-master.zip failed!"
        fifth_cleanup
        exit 1
    fi

    cd ${cur_dir}/shadowsocks-master
    python setup.py install --record /usr/local/shadowsocks_install.log

    if [ -f /usr/bin/ssserver ] || [ -f /usr/local/bin/ssserver ]; then
        chmod +x /etc/init.d/shadowsocks
        update-rc.d -f shadowsocks defaults
        /etc/init.d/shadowsocks start
    else
        echo
        echo -e "${FAIL} shadowsocks install failed! please email waveworkshop@outlook.com to contact me."
        fifth_cleanup
        exit 1
    fi
    printf "shadowsocks server installing..."
    sleep 1
    clear
    echo
    echo -e "#-----------------------------------------------------#"
    echo -e "#         ${CYAN}Server${PLAIN}: ${RED} $(get_ip) ${PLAIN}"
    echo -e "#           ${CYAN}Port${PLAIN}: ${RED} ${shadowsocks_port} ${PLAIN}"
    echo -e "#       ${CYAN}Password${PLAIN}: ${RED} ${shadowsocks_passwd} ${PLAIN}"
    echo -e "# ${CYAN}Encrypt Method${PLAIN}: ${RED} ${shadowsocks_method} ${PLAIN}"
    echo -e "#   ${CYAN}TCP FastOpen${PLAIN}: ${RED} ${shadowsocks_fastopen} ${PLAIN}"
    echo -e "#-----------------------------------------------------#"
    echo
}

# Cleanup install files
fifth_cleanup(){
    cd ${cur_dir}
    rm -rf shadowsocks-master.zip shadowsocks-master libsodium-latest.tar.gz libsodium-1.*
}

# Optimize the shadowsocks server on Linux
optimize_kernel(){
    # First of all, make sure your Linux kernel is 3.5 or later please.
    local LIMVER=3.4
    # Step 1, increase the maximum number of open file descriptors
    if [ `echo "$COREVER > $LIMVER" | bc` -eq 1 ]; then
        # Backup default config
        cp /etc/security/limits.conf /etc/security/limits.conf.bak
        cp /etc/sysctl.conf /etc/sysctl.conf.bak
        # To handle thousands of concurrent TCP connections, we should increase the limit of file descriptors opened.
        echo "* soft nofile 51200" >> /etc/security/limits.conf
        echo "* hard nofile 51200" >> /etc/security/limits.conf
    else
        exit 1
    fi
    # To use BBR, make sure your Linux kernel is 4.9 or later please.
    local TCP_BBR=4.8
    # Step 2, Tune the kernel parameters
    if [ `echo "$COREVER > $TCP_BBR" | bc` -eq 1 ]; then
        # Use Google BBR
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
    else
        # The priciples of tuning parameters for shadowsocks are
        # 1.Reuse ports and conections as soon as possible.
        # 2.Enlarge the queues and buffers as large as possible.
        # 3.Choose the TCP congestion algorithm for large latency and high throughput.
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
    fi
    # reload the config at runtime.
    sysctl -p 1> /dev/null
}

# Uninstall Shadowsocks
uninstall_shadowsocks(){
    echo -e "${WARNING}Are you sure uninstall shadowsocks? (y/n) "
    read -p "(Default: n):" answer
    [ -z ${answer} ] && answer="n"
    if [ "${answer}" == "y" ] || [ "${answer}" == "Y" ]; then
        ps -ef | grep -v grep | grep -i "ssserver" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            /etc/init.d/shadowsocks stop
        fi
        # Remove system config
        update-rc.d -f shadowsocks remove
        # Restore system config
        rm -f /etc/security/limits.conf
        rm -f /etc/sysctl.conf
        mv /etc/security/limits.conf.bak /etc/security/limits.conf
        mv /etc/sysctl.conf.bak /etc/sysctl.conf
        # Delete config file
        rm -f /etc/shadowsocks.json
        rm -f /var/run/shadowsocks.pid
        rm -f /etc/init.d/shadowsocks
        rm -f /var/log/shadowsocks.log
        if [ -f /usr/local/shadowsocks_install.log ]; then
            cat /usr/local/shadowsocks_install.log | xargs rm -rf
        fi
        echo "shadowsocks uninstall success! "
    else
        echo
        echo -e "${CANCEL}Cancelled, nothing to do. "
        echo
    fi
}

# Install main function
install_shadowsocks(){
    first_set_config
    second_download_files
    third_write_config
    fourth_install
    fifth_cleanup
}

# OS
OSID=$(grep ^ID= /etc/os-release | cut -d= -f2)
OSVER=$(lsb_release -cs)
OSNUM=$(grep -oE  "[0-9.]+" /etc/issue)
COREVER=$(uname -r | grep -Eo '[0-9].[0-9]+' | sed -n '1,1p')
MEMKB=$(cat /proc/meminfo | grep MemTotal | awk -F':' '{print $2}' | grep -o '[0-9]\+')
INSTALL_MARK=0

# RedHat not support
if [ -s /etc/redhat-release ]; then
    clear
    echo -e "${ERROR} RedHat and CentOS is not supported. Please reinstall to Debian / Ubuntu and try again."
    exit 1
fi

# Debian & Ubuntu
case "$OSVER" in
    unstable|sid)
    	# Debian unstable
        clear
        echo -e "${WARNING} We strongly encourage you to use stable release."
        exit 1
	    ;;
    jessie)
    	# Debian 8.0 jessie
        INSTALL_MARK=1
	    ;;
    stretch)
        # Debian 9.0 stretch
        INSTALL_MARK=1
        ;;
    xenial)
	    # Ubuntu 16.04 xenial
        INSTALL_MARK=1
	    ;;
    yakkety)
        # Ubuntu 16.10 yakkety
        INSTALL_MARK=1
        ;;
    zesty)
        # Ubuntu 17.04 zesty
        INSTALL_MARK=1
        ;;
    *)
        echo -e "${ERROR} Sorry,$OSID $OSVER is too old, please update to retry."
        exit 1
        ;;
esac

echo -e "#############################################################"
echo -e "#       ${RED}OS${PLAIN}: $OSID $OSNUM $OSVER "
echo -e "#   ${RED}Kernel${PLAIN}: $(uname -m) Linux $(uname -r)"
echo -e "#      ${RED}CPU${PLAIN}: $(grep 'model name' /proc/cpuinfo | uniq | awk -F : '{print $2}' | sed 's/^[ \t]*//g' | sed 's/ \+/ /g') "
echo -e "#      ${RED}RAM${PLAIN}: $(cat /proc/meminfo | grep 'MemTotal' | awk -F : '{print $2}' | sed 's/^[ \t]*//g') "
echo -e "#############################################################"
echo

# Initialization step
case "$1" in
    install)
        rootness
        if [ $INSTALL_MARK -eq 1 ]; then
            $1_shadowsocks
        fi
        if [ $OPTIMIZE_MARK -eq 1 ]; then
            optimize_kernel
        fi
        ;;
    uninstall)
        rootness
        $1_shadowsocks
        ;;
    *)
        clear
        echo "Usage: $0 [install|uninstall]"
        exit 1
        ;;
esac

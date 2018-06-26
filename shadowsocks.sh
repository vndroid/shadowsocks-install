#!/usr/bin/env bash

# shadowsocks.sh - a CLI Bash script to install shadowsocks server automatic for Debian / Ubuntu

# Copyright (c) 2016-2018 Wave WorkShop <waveworkshop@outlook.com>

#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

scriptVersion="3.0.2"
scriptDate="20180626"

clear
echo
echo "#############################################################"
echo "# shadowsocks python server install for Debian / Ubuntu     #"
echo "# Thanks: @clowwindy <https://twitter.com/clowwindy>        #"
echo "# Author: Wave WorkShop <waveworkshop@outlook.com>          #"
echo "# Github: https://github.com/shadowsocks/shadowsocks        #"
echo "#############################################################"
echo

# Set color
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

# Font Format
BOLD="\033[1m"
UNDERLINE="\033[4m"

# Current folder
cur_dir=`pwd`

# Make sure root user
rootNess(){
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
setupProfile(){
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
    echo "method = ${shadowsocks_method}"
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
    echo "Do you want to enable TCP-FastOpen for shadowsocks? (y/n)"
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
    # Prepare finish
    echo
    echo -e "Press any key to start...or Press ${RED}Ctrl+C${PLAIN} to cancel"
    char=`get_char`
    # Install necessary dependencies
    apt -y update
    apt -y install python python-dev python-pip python-setuptools python-m2crypto curl wget unzip gcc swig automake make perl cpio build-essential
    # Return Home
    cd ${cur_dir}
}

# Download files
downloadFiles(){
    # Download file
    if [ ! -f LATEST.tar.gz ]; then
        if ! wget --no-check-certificate https://download.libsodium.org/libsodium/releases/LATEST.tar.gz; then
            echo "Failed to download libsodium file!"
        fi
    fi
    if [ ! -f master.zip ]; then
        if ! wget --no-check-certificate https://github.com/shadowsocks/shadowsocks/archive/master.zip; then
            echo "Failed to download shadowsocks python file!"
        fi
    fi
    if [ ! -f /etc/init.d/shadowsocks ]; then
        if ! wget --no-check-certificate https://raw.githubusercontent.com/wavengine/shadowsocks-install/master/shadowsocks -O /etc/init.d/shadowsocks; then
            echo "Failed to download shadowsocks daemon file!"
        fi
    fi
}

# Write shadowsocks config
writeProfile(){
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

# Compile shadowsocks
compile_install(){
    # Install libsodium
    tar zxvf LATEST.tar.gz
    pushd libsodium-stable
    ./configure && make -j2 && make install
    if [ $? -ne 0 ]; then
        echo -e "${FAIL}libsodium install failed!"
        cleanUp
        exit 1
    fi
    ldconfig
    popd
    # Install shadowsocks
    cd ${cur_dir}
    unzip -q master.zip
    if [ $? -ne 0 ]; then
        echo -e "${FAIL} unzip master.zip failed!"
        cleanUp
        exit 1
    fi

    cd ${cur_dir}/shadowsocks-master
    python setup.py install --record /usr/local/shadowsocks_install.log

    if [ -f /usr/bin/ssserver ] || [ -f /usr/local/bin/ssserver ]; then
        chmod +x /etc/init.d/shadowsocks
        update-rc.d -f shadowsocks defaults
        /etc/init.d/shadowsocks start
    else
        echo -e "${FAIL} shadowsocks install failed! please email error log to ${RED}waveworkshop@outlook.com${PLAIN}."
        cleanUp
        exit 1
    fi
    printf "shadowsocks server installing..."
    sleep 1
    clear
    echo
    echo -e "#-----------------------------------------------------#"
    echo -e "#         ${CYAN}Server${PLAIN}: ${RED} $(get_ip) ${PLAIN}"
    echo -e "#           ${CYAN}Port${PLAIN}: ${RED} $shadowsocks_port ${PLAIN}"
    echo -e "#       ${CYAN}Password${PLAIN}: ${RED} $shadowsocks_passwd ${PLAIN}"
    echo -e "# ${CYAN}Encrypt Method${PLAIN}: ${RED} $shadowsocks_method ${PLAIN}"
    echo -e "#   ${CYAN}TCP FastOpen${PLAIN}: ${RED} $shadowsocks_fastopen ${PLAIN}"
    echo -e "#-----------------------------------------------------#"
    echo
}

# Cleanup install files
cleanUp(){
    cd ${cur_dir}
    rm -rf master.zip shadowsocks-master LATEST.tar.gz
}

# Optimize the shadowsocks server on Linux
optimizeShadowsocks(){
    # Step 1, First of all, make sure your Linux kernel is 3.5 or later please.
    local LIMVER1=3
    local LIMVER2=5
    # Step 2, Extract kernel value
    local COREVER1=$(echo $COREVER | awk -F '.' '{print $1}')
    local COREVER2=$(echo $COREVER | awk -F '.' '{print $2}')
    # Step 3, increase the maximum number of open file descriptors
    if [ `echo "$COREVER1 >= $LIMVER1" | bc` -eq 1 ]; then
        if [ `echo "$COREVER2 >= $LIMVER2" | bc` -eq 1 ]; then
            # Backup default file
            cp -a /etc/security/limits.conf /etc/security/limits.conf.bak
            # To handle thousands of current TCP connections, we should increase the limit of file descriptors opened.
            echo -e "* soft nofile 51200 \n* hard nofile 51200" >> /etc/security/limits.conf
            # Set the ulimit
            ulimit -n 51200
        else
            echo "Linux kernel not support"
        fi
    else
        exit 1
    fi
    # Step 4, To use BBR, make sure your Linux kernel is 4.9 or later please.
    local TCP_BBR1=4
    local TCP_BBR2=9
    # Step 5, Tune the kernel parameters
    if [ `echo "$COREVER1 >= $TCP_BBR1" | bc` -eq 1 ]; then
        if [ `echo "$COREVER2 >= $TCP_BBR2" | bc` -eq 1 ]; then
            # Backup default file
            cp -a /etc/sysctl.conf /etc/sysctl.conf.bak
            # Use Google BBR
            cat >> /etc/sysctl.conf <<EOF
fs.file-max = 51200
            
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.core.default_qdisc = fq
            
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = bbr
EOF
        else
            # The priciples of tuning parameters for shadowsocks are
            # 1.Reuse ports and conections as soon as possible.
            # 2.Enlarge the queues and buffers as large as possible.
            # 3.Choose the TCP congestion algorithm for large latency and high throughput.
            cat >> /etc/sysctl.conf <<EOF
fs.file-max = 51200

net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = hybla
EOF
        fi
        # reload the config at runtime.
        sysctl -p 1> /dev/null
    else
        echo "The kernel ($COREVER1.$COREVER2)is too old, can not use BBR. Use hybla "
    fi
}

# Display Help info
displayHelp(){
	echo "${UNDERLINE}Usage${PLAIN}:"
	echo "  $0 [OPTIONAL FLAGS]"
	echo
	echo "shadowsocks.sh - a CLI Bash script to install shadowsocks server automatic for Debian / Ubuntu."
	echo
	echo "${UNDERLINE}Options${PLAIN}:"
    echo "   ${BOLD}-i, --install${PLAIN}      Install shadowsocks."
    echo "   ${BOLD}-u, --uninstall${PLAIN}    Uninstall shadowsocks."
	echo "   ${BOLD}-v, --version${PLAIN}      Display current script version."
	echo "   ${BOLD}-h, --help${PLAIN}         Display this help."
    echo
    echo "${UNDERLINE}shadowsocks.sh${PLAIN} - Version ${scriptVersion} "
    echo "Modify Date ${scriptDate}"
	echo "Created by and licensed to WaveWorkShop <waveworkshop@outlook.com>"
}

# Uninstall Shadowsocks
uninstallShadowsocks(){
    echo -e "${WARNING} Are you sure uninstall shadowsocks and libsodium? (y/n) "
    read -p "(Default: n):" answer
    [ -z ${answer} ] && answer="n"
    if [ "${answer}" == "y" ] || [ "${answer}" == "Y" ]; then
        ps -ef | grep -v grep | grep -i "ssserver" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            /etc/init.d/shadowsocks stop
        fi
        # Remove daemon
        update-rc.d -f shadowsocks remove
        # Restore system config
        if [ -f /etc/security/limits.conf.bak ]; then
            rm -f /etc/security/limits.conf
            mv /etc/security/limits.conf.bak /etc/security/limits.conf
        fi
        if [ -f /etc/sysctl.conf.bak ]; then
            rm -f /etc/sysctl.conf
            mv /etc/sysctl.conf.bak /etc/sysctl.conf
        fi
        # Delete config file and log file
        rm -f /etc/shadowsocks.json
        rm -f /var/run/shadowsocks.pid
        rm -f /etc/init.d/shadowsocks
        rm -f /var/log/shadowsocks.log
        if [ -f /usr/local/shadowsocks_install.log ]; then
            cat /usr/local/shadowsocks_install.log | xargs rm -rf
        fi
        # Uninstall libsodium(can case other issues)
        if [ -d libsodium-stable ]; then
            cd libsodium-stable
            make && make uninstall
        else
            echo "no directory. can not uninstall libsodium."
        fi
        echo "shadowsocks uninstall success! "
    else
        echo -e "${CANCEL}Cancelled, nothing to do. "
    fi
}

# Install main function
installShadowsocks(){
    setupProfile
    downloadFiles
    writeProfile
    startInstall
    cleanUp
}

# Distro Detection
type apt >/dev/null 2>&1
if [ $? -eq 0 ];then
    # necessary depend μ
    apt -y install bc lsb-release
else 
    if [ -s /etc/redhat-release ]; then
        if [ -s /etc/centos-release ]; then
            CENTOSVER=$(rpm -q centos-release | cut -d- -f3)
            clear
            echo -e "${ERROR} ${GREEN}CentOS${PLAIN} ${GREEN}${CENTOSVER}${PLAIN} is not supported. Please reinstall to Debian / Ubuntu and try again."
            exit 1
        else
            RADHATVER=$(cat /etc/redhat-release | sed -r 's/.* ([0-9]+)\..*/\1/')
            clear
            echo -e "${ERROR} ${GREEN}RedHat${PLAIN} ${GREEN}${RADHATVER}${PLAIN} is not supported. Please reinstall to Debian / Ubuntu and try again."
            exit 1
        fi
    fi
fi

# OS
OSID=$(grep ^ID= /etc/os-release | cut -d= -f2)
OSVER=$(lsb_release -cs)
OSNUM=$(grep -oE  "[0-9.]+" /etc/issue)
COREVER=$(uname -r | grep -Eo '[0-9].[0-9]+' | sed -n '1,1p')
MEMKB=$(cat /proc/meminfo | grep MemTotal | awk -F':' '{print $2}' | grep -o '[0-9]\+')
MEMMB=$(expr $MEMKB / 1024)
MEMGB=$(expr $MEMMB / 1024)
INSMARK=0

# Debian & Ubuntu
case "$OSVER" in
    wheezy)
        # Debian 7.0 wheezy
        INSMARK=1
        ;;
    jessie)
    	# Debian 8.0 jessie
        INSMARK=1
	    ;;
    stretch)
        # Debian 9.0 stretch
        INSMARK=1
        ;;
    trusty)
        # Ubuntu 14.04 trusty LTS
        INSMARK=1
        ;;
    xenial)
	    # Ubuntu 16.04 xenial LTS
        INSMARK=1
	    ;;
    bionic)
        # Ubuntu 18.04 bionic LTS
	    INSMARK=1
        ;;
    *)
        echo -e "${ERROR} Sorry,$OSID $OSVER is too old or unsupport, please update to retry."
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
    install|-i|--install)
        rootNess
        if [ $INSMARK -eq 1 ]; then
            installShadowsocks
        fi
        optimizeShadowsocks
        ;;
    uninstall|-u|--uninstall)
        rootNess
        uninstallShadowsocks
        ;;
    *)
        clear
        displayHelp
        exit 0
        ;;
esac
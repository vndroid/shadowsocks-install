# shadowsocks server install

## Intro

[Shadowsocks](https://shadowsocks.org) is a secure SOCKS5 proxy, designed to protect your Internet traffic.

Current version: 3.0(02) | [Changelog](/change.log)

Current lauguage: English | [Simplified Chinese](/README_CN.md)


## Summary

This script can compile and install for Linux server automatic by [@Vndroid](https://github.com/Vndroid/)

## Features

Automatically deploy servers and Optimize the shadowsocks server on Linux.

## Support:

* Debian 7 *Wheezy*
* Debian 8 *Jessie*
* Debian 9 *Stretch*
* Debian 10 *Buster*
* Ubuntu 14.04 *Trusty*
* Ubuntu 16.04 *Xenial*
* Ubuntu 18.04 *Bionic*

## How to use:

### Download

```bash
# wget https://raw.githubusercontent.com/Vndroid/shadowsocks-install/master/shadowsocks.sh
# chmod +x shadowsocks.sh
```

### Install

```bash
# ./shadowsocks.sh install 2>&1 | tee shadowsocks.log
```

> Notice: Must be as root user run this command.

### Uninstall

```bash
# ./shadowsocks.sh uninstall
```

### Configure and start the service

Edit the configuration file

```bash
# vi /etc/shadowsocks.json
```

Start the service via sysvinit

```bash
# /etc/init.d/shadowsocks start
```

Stop the service via sysvinit

```bash
# /etc/init.d/shadowsocks stop
```

Check service status

```bash
# /etc/init.d/shadowsocks status
```

View the shadowsocks server log

```bash
# tail -f /var/log/shadowsocks.log
```

## Report issues

Email Me: waveworkshop@outlook.com
With the "shadowsocks.log"

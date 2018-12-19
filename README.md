# shadowsocks server install

## Intro

[Shadowsocks](https://shadowsocks.org) is a secure SOCKS5 proxy, designed to protect your Internet traffic.

Current version: 3.0(02) | [Changelog](/change.log)

Current lauguage: English | [Simplified Chinese](/README_CN.md)


## Summary

This script can compile and install for Linux server automatic by [@wavengine](https://github.com/wavengine)

## Features

Automatically deploy servers and Optimize the shadowsocks server on Linux.

## Support:

* Debian 7.0 *Wheezy*
* Debian 8 *Jessie*
* Debian 9 *Stretch*
* Ubuntu 14.04 *Trusty*
* Ubuntu 16.04 *Xenial*
* Ubuntu 18.04 *Bionic*

## How to use:

### Download

```bash
# wget https://raw.githubusercontent.com/wavengine/shadowsocks-install/master/shadowsocks.sh
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

```bash
# vi /etc/shadowsocks.json
```

> Edit the configuration file

```bash
# /etc/init.d/shadowsocks start
```

> Start the service via sysvinit

```bash
# /etc/init.d/shadowsocks stop
```

> Stop the service

```bash
# /etc/init.d/shadowsocks status
```

> Check service status

```bash
# tail -f /var/log/shadowsocks.log
```

>  View the log

## Report issues

Email Me: waveworkshop@outlook.com
With the "shadowsocks.log"

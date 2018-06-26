# shadowsocks server install

## Intro

[Shadowsocks](https://shadowsocks.org) is a secure SOCKS5 proxy, designed to protect your Internet traffic.

Current version: 3.0(01) | [Changelog](/change.log)

Current lauguage: English | [Simplified Chinese](/README_CN.md)


## Summary

This script can compile and install for Linux server automatic by [@wavengine](https://github.com/wavengine)

## Features

Automatically deploy servers and Optimize the shadowsocks server on Linux.

## Support:

* Debian 8 *Jessie*
* Debian 9 *Stretch*
* Ubuntu 14.04 *Trusty*
* Ubuntu 16.04 *Xenial*
* Ubuntu 18.04 *Bionic*

## How to use:

### Install
```bash
wget https://raw.githubusercontent.com/wavengine/shadowsocks-install/master/shadowsocks.sh
chmod +x shadowsocks.sh
./shadowsocks.sh install 2>&1 | tee shadowsocks.log
```

### Uninstall

```bash
./shadowsocks.sh uninstall
```

### Configure and start the service
```
# Edit the configuration file
vi /etc/shadowsocks.json

# Start the service
/etc/init.d/shadowsocks start    # for sysvinit

# Stop the service
/etc/init.d/shadowsocks stop

# Check service status
/etc/init.d/shadowsocks status

# View the log
tail -f /var/log/shadowsocks.log
```

## Report issues

Email Me: waveworkshop@outlook.com
With the "shadowsocks.log"

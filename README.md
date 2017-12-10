# shadowsocks server install

## Intro

[Shadowsocks](https://shadowsocks.org) is a secure SOCKS5 proxy, designed to protect your Internet traffic.

Current version: 2.0(06) | [Changelog](/change.log)


## Summary

This script can compile and install for Linux server automatic by [@wavengine](https://github.com/wavengine)

## Features

Automatically deploy servers and Optimize the shadowsocks server on Linux.

## Support:

* Debian 8 *Jessie*
* Debian 9 *Stretch*
* Ubuntu 14.04 *Trusty*
* Ubuntu 16.04 *Xenial*
* Ubuntu 16.10 *Yakkety*
* Ubuntu 17.04 *Zesty*

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
```

## Report issues

Email Me: waveworkshop@outlook.com
With the "shadowsocks.log"

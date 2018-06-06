# shadowsocks 服务端安装

## 

[Shadowsocks](https://shadowsocks.org) 是一个安全的 SOCKS5 代理，为保护你的网络通信设计。

当前语言：简体中文 | [英文版](/README.md)


## 概要

本脚本可以帮助用户全自动编译安装 Shadowsocks Linux 服务端

## 特性

自动部署服务端并且可一键优化（仅支持 Linux 相关优化）

## 支持

* Debian 8 *Jessie*
* Debian 9 *Stretch*
* Ubuntu 14.04 *Trusty*
* Ubuntu 16.04 *Xenial*
* Ubuntu 18.04 *Bionic*

## 使用方法

### 安装
```bash
wget https://raw.githubusercontent.com/wavengine/shadowsocks-install/master/shadowsocks.sh
chmod +x shadowsocks.sh
./shadowsocks.sh install 2>&1 | tee shadowsocks.log
```

### 卸载

```bash
./shadowsocks.sh uninstall
```

### 配置并启动
```
# 修改配置文件
vi /etc/shadowsocks.json

# 开启服务
/etc/init.d/shadowsocks start

# 停止服务
/etc/init.d/shadowsocks stop

# 检查服务状态
/etc/init.d/shadowsocks status
```

## 问题反馈

邮箱： waveworkshop@outlook.com
请附带脚本执行日志（shadowsocks.log）以便复现修复。

# shadowsocks 服务端安装

[Shadowsocks](https://shadowsocks.org) 是一个安全的 SOCKS5 代理，为保护你的网络通信设计。

当前语言：简体中文 | [英文版](/README.md)


## 概要

本脚本可以帮助用户全自动编译安装 shadowsocks Linux 服务端

## 特性

自动部署服务端并且支持一键优化（仅支持 Linux 相关优化）内核 4.9 以上自动开启 BBR ，对连接数、文件打开数等全部进行优化。

## 支持

* Debian 7 *Wheezy*
* Debian 8 *Jessie*
* Debian 9 *Stretch*
* Debian 10 *Buster*
* Ubuntu 14.04 *Trusty*
* Ubuntu 16.04 *Xenial*
* Ubuntu 18.04 *Bionic*

## 使用方法

### 安装

下载脚本

```bash
# wget https://raw.githubusercontent.com/Vndroid/shadowsocks-install/master/shadowsocks.sh
```

授权脚本

```bash
# chmod +x shadowsocks.sh
```

执行脚本并生成日志

```bash
# ./shadowsocks.sh install 2>&1 | tee shadowsocks.log
```

### 卸载

```bash
# ./shadowsocks.sh uninstall
```

### 配置并启动

修改配置

```bash
# vi /etc/shadowsocks.json
```

启动服务

```bash
# /etc/init.d/shadowsocks start

停止服务

```bash
# /etc/init.d/shadowsocks stop
```

服务状态

```bash
# /etc/init.d/shadowsocks status
```

查看日志

```bash
# tail -f /var/log/shadowsocks.log
```

## 问题反馈

邮箱： waveworkshop@outlook.com
请附带脚本执行日志（shadowsocks.log）以便修复。

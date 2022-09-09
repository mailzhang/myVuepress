# 虚拟专用网快速搭建

## 执行安装部署脚本
```shell
wget --no-check-certificate https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocksR.sh
chmod +x shadowsocksR.sh
./shadowsocksR.sh 2>&1 | tee shadowsocksR.log
```

密码： 默认即可    注意纯数字密码可能无法使用


1.端口选择

尽量随机 19283

2.加密算法

aes-256-cfb

3.协议选择
auth_aes128_sha1

4.选择混淆

tls1.2_ticket_auth

命令备份
```
启动：/etc/init.d/shadowsocks start
停止：/etc/init.d/shadowsocks stop
重启：/etc/init.d/shadowsocks restart
卸载：./shadowsocksR.sh uninstall(cd到下载脚本的路径)
配置文件：/etc/shadowsocks.json
日志文件：/var/log/shadowsocks.log
查看运行状态：/etc/init.d/shadowsocks status
查看端口：netstat -an(查看安装时选择的端口是否监听)
查看进程：ps -ef(查看进程脚本是否启动)
```


## 客户端安装

ssr客户端

```
https://itlanyan.com/shadowsockr-shadowsocksr-shadowsocksrr-clients/
```

chrome插件
```
https://chrome.google.com/webstore/detail/proxy-switchyomega/padekgcemlokbadohgkifijomclgjgif?hl=zh-CN
```

## 配置bbr加速
```
wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh && chmod +x bbr.sh && ./bbr.sh

```
输入 y 重启服务器

查看内核版本，内核版本显示为最新版就表示 BBR 加速安装完成
```
uname -r

```

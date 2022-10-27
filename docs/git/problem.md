

# git 常见问题
## fatal: unable to access 'https://github.com/nefulan/MyVuepress.git/': Failed to connect to github.com port 443: Timed out
```shell
git config --global --unset http.proxy
git config --global --unset https.proxy
```

OpenSSL SSL_read: Connection was reset, errno 10054
```shell
git config --global http.sslVerify "false"
```

# mac安装brew包错
## curl: (7) Failed to connect to raw.githubusercontent.com port 443: Connection refused
https://zhuanlan.zhihu.com/p/115450863
```shell
# 7890 和 789 需要换成你自己本地监听的端口
export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:789
```

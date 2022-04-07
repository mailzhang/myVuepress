

# git 常见问题
## fatal: unable to access 'https://github.com/nefulan/MyVuepress.git/': Failed to connect to github.com port 443: Timed out
```shell
git config --global --unset http.proxy
git config --global --unset https.proxy
```
# !bin/bash 

npm run docs:build
docker pull nginx

docker run --name myVuepress -p 80:80 -v /root/myVuepress/nginx.conf:/etc/nginx/nginx.conf -v /root/myVuepress/docs/.vuepress/dist:/usr/share/nginx/html/dist -d nginx

# !bin/bash 

docker pull nginx

docker run --name myVuepress -p 80:80 -v nginx.conf:/etc/nginx/nginx.conf -v docs/dist:/usr/share/nginx/html/dist -d nginx

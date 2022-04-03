# !bin/bash 

docker pull nginx

docker run --name myVuepress -p 80:80 -v nginx.conf:/usr/share/nginx/html -v docs/dist:/usr/share/nginx/html -d nginx

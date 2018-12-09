# alpine nginx docker container



基于alpine的nginx 容器



默认nginx用户为 www-data



默认工作目录目录：  /home/wwwroot

      #fastcgi_pass php:9000;

使用nginx自带参数 -s 停止nginx
/usr/local/nginx/nginx -s stop



To reload the NGINX configuration, run this command:

docker kill -s HUP nginx



To restart NGINX, run this command to restart the container:

docker restart nginx



kill -HUP 【旧的主进程号】：nginx 将在不重载配置文件的情况下启动它的工作进程

kill -QUIT 【新的主进程号】：从容关闭其工作进程(worker process)

kill -TERM 【新的主进程号】：强制退出

kill 【新的主进程号或旧的主进程号】：如果因为某些原因新的工作进程不能退出，则向其发送 kill 信号



## nginx配置示例

```conf
server {
    listen 80;
    server_name _;
    root /home/wwwroot/myweb/public;
    index index.php index.html index.htm;
    #error_page 404 /404.html;
    #error_page 502 /502.html;

   # for laravel rewrite
   # location / {
    #    try_files $uri /index.php?$args;
   # }
   
   #rewrite for thinkphp
   if (!-e $request_filename) {
     rewrite "^/(.*)"  /index.php?s=/$1 last;
     break;
   }
  # 与php容器协同工作
   location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
    #静态资源缓存配置
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|mp4|ico)$ {
      expires 30d;
      access_log off;
    }
    location ~ .*\.(js|css)?$ {
      expires 7d;
      access_log off;
    }
    location ~ /\.ht {
      deny all;
    }
  }
```



## nginx + php-fpm+mariadb/mysql 容器协同工作配置示例

```yml

# nginx容器 yml配置

nginx:
  image: tekintian/nginx:1.15.7-alpine
  privileged: false
  restart: always
  external_links:
  - php70fpm_1:php
  - mariadb:db
  ports:
  - '80:80'


# PHP容器yml配置

php70fpm:
  image: tekintian/php:7.0-fpm-alpine
  privileged: false
  restart: always
  ports:
  - '9070:9000'
  volumes:
  - /home/wwwroot:/home/wwwroot
#  - /home/dcdata/php70fpm/etc:/usr/local/etc
  external_links:
  - mariadb:db


# mariadb yml配置

mariadb104:
  image: library/mariadb:10.4
  privileged: false
  restart: always
  ports:
  - '3304:3306'
  volumes:
  - /home/dcdata/mariadb104/conf.d:/etc/mysql/conf.d
  - /home/dcdata/mariadb104/data:/var/lib/mysql
  environment:
  - MYSQL_ROOT_PASSWORD=888888
  - character-set-server=utf8mb4
  - collation-server=utf8mb4_unicode_ci


# 然后在nginx容器中就 可以使用  db 作为数据库的服务器地址来用了，注意端口是3306 不是你对外暴露的端口。
```





## Support 技术支持

​	需要其他的特定环境或则模块支持，可联系定制开发容器 ， Email: tekintian@gmail.com  QQ:932256355





如果您觉得本项目对您有用，请打赏支持开发，谢谢！

![donate](donate.png)














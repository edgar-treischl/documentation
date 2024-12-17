

```bash
sudo mkdir -p /var/www/shiny.edgar-treischl.de/html

sudo chown -R $USER:$USER /var/www/shiny.edgar-treischl.de/html

sudo chmod -R 755 /var/www//shiny.edgar-treischl.de

nano /var/www/shiny.edgar-treischl.de/html/index.html

sudo nano /etc/nginx/sites-available/shiny.edgar-treischl.de



server {

        listen 80;

        listen [::]:80;

  

        root /var/www/shiny.edgar-treischl.de/html;

        index index.html index.htm index.nginx-debian.html;

  

        server_name shiny.edgar-treischl.de www.shiny.edgar-treischl.de;

  

        location / {

                try_files $uri $uri/ =404;

        }

}

  

  

sudo ln -s /etc/nginx/sites-available/shiny.edgar-treischl.de /etc/nginx/sites-enabled/

  

  

‚Part2

  

sudo nano /etc/nginx/sites-available/shiny.edgar-treischl.de

  

sudo certbot --nginx -d shiny.edgar-treischl.de -d www.shiny.edgar-treischl.de

  

  

sudo nano please_proxy_my_shiny_server.conf

  

  

  

  

  

server_name rstudio.edgar-treischl.de www.rstudio.edgar-treischl.de;

  

location / {

                # block added from rstudio support doc

                proxy_pass http://localhost:3838;

                proxy_redirect / $scheme://$http_host/;

                proxy_http_version 1.1;

                proxy_set_header Upgrade $http_upgrade;

                proxy_set_header Connection $connection_upgrade;

                proxy_read_timeout 20d;

                proxy_buffering off;

}

  

  

  

  

  

  

  

  

https://weihanglo.tw/debian-R-setup/doc/other_nginx.html:

  

https://deanattali.com/2015/05/09/setup-rstudio-shiny-server-digital-ocean/

  

First: Put the map block into the http block of your nginx configuration. The default file path for the nginx config is 

/etc/nginx/nginx.conf.

  

+       map $http_upgrade $connection_upgrade {

+           default upgrade;

+           ''      close;

+       }

  

  

Second: add a server block with in the http block

http {

  

  # other config blocks...

  

  server {

    # some configuration

    # set your config here

  }

}

  

  

Next:

  server {

    server_name your.domain;

  }

  

  

Finally; insert the redirect inside of the sever function

  

Next Insert the redirect:

  

  server {

    server_name your.domain;

    location /shiny/ { # shiny server will locate at `http://example.domain/shiny/`

      rewrite ^/shiny/(.*)$ /$1 break;

      proxy_pass http://localhost:3838;

      proxy_redirect http://localhost:3838/ $scheme://$host/shiny/;

      proxy_http_version 1.1;

      proxy_set_header Upgrade $http_upgrade;

      proxy_set_header Connection $connection_upgrade;

      proxy_read_timeout 20d;

  }

  }

  

  

And for a login for RStudio:

  location /login/ { # shiny server will locate at `http://example.domain/shiny/`

    rewrite ^/login/(.*)$ /$1 break;

    proxy_pass http://localhost:8383;

    proxy_redirect http://localhost:8383/ $scheme://$host/login/;

    proxy_http_version 1.1;

    proxy_set_header Upgrade $http_upgrade;

    proxy_set_header Connection $connection_upgrade;

    proxy_read_timeout 20d;

  }
  ```



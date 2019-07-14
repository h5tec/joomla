## Joomla Container
_by H5.Technology_ **`[admin@h5tec.com]`**  

**`debian:stretch`** **`joomla:3.9.10`** **`php:7.2`** **`apache2`**  

### PHP 7.2 Packages
**`cli`** **`curl`** **`gd mysql`** **`zip`** **`xml`** **`ldap`** **`mbstring`** **`common`** **`json`** **`opcache`** **`readline`** **`intl`** **`fpm`**

### Included 
* **`php.ini`**    
```ini
upload_max_filesize=16M
post_max_size=16M
max_execution_time=60
```
* **`apache2.conf`**
```ini
<IfModule mod_env.c>
  SetEnv HTTPS on
</IfModule>
```

### Run Container by CommandLine
```docker
docker run -d --restart=always --name myjoomla -p 8080:80 -v /dock/data/myjoomla/logs:/var/log/apache2 -v /dock/data/myjoomla/html:/var/www/html/joomla enbucm/joomla
```

### Compose Joomla together with MySQL and PHPmyAdmin
* **`docker-compose.yaml`**
```yaml
version: 3.1
  services:
    joomla:
      image: h5tec/joomla
      restart: always
      links:
        - mysql:mysql
      ports:
        - 8001:80
    mysql:
      image: mysql:5.7
      restart: always
      environment:
        MYSQL_ROOT_PASSWORD: YourPassword
        MYSQL_DATABASE: YourDatabaseName
        MYSQL_USER: YourUserName
        MYSQL_PASSWORD: YourSecurePassword
    phpmyadmin:
      image: phpmyadmin/phpmyadmin
      restart: always
      links:
        - mysql:mysql
      ports:
        - 9001:80
      environment:
        MYSQL_USERNAME: root
        MYSQL_ROOT_PASSWORD: YourRootPasswordFromMySQL
        PMA_HOST: mysql
```

### Full Enviroment
* Install packages
```bash
apt install -y ufw nginx python-certbot-nginx
```
* Configure UFW [Uncomplicated FireWall]
```bash
ufw allow 'Nginx Full'
```
* Create Nginx Congfiguration change **`example.org`** to your domainname  
**`nano /etc/nginx/conf.d/example.org.conf`**
```conf
server {
  listen 80;
  server_name example.org;
  location /.well-known/acme-challenge/ {
    root /var/www/certbot;
  }
  location / {
    return 301
    https://$host$request_uri;
  }
}
server {
  listen 443 ssl;
  server_name example.org;
  location / {
    proxy_pass         http://localhost:8001;
    proxy_redirect     http:// https://;
    proxy_set_header   Host $host;
    proxy_set_header   X-Real-IP $remote_addr;
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Host $server_name;
  }
  client_max_body_size 16M;
  # SSL certificate path will be added by certbot automaticly
}
```
* Check nginx configuration **`nginx -t`**
* Restart nginx **`service nginx restart`**
* Optain LetsEncrypt Certificate
```bash
certbot --nginx -d example.org
```
* Check the new certificates  
https://www.ssllabs.com/ssltest/analyze.html?d=example.org

_...f i n i s h e d_  
  
_Certbot check for new certificate twice a day via_  
**`/etc/systemd/system/timers.target.wants/certbot.timer``**  
  
_Certbot timer status can be checked with_  
**`systemctl status certbot.timer`**  


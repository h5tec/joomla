## Joomla Container
_by H5.Technology_ **`[admin@h5tec.com]`**  

**`debian:stretch`** **`joomla:3.9.10`** **`php:7.2`** **`apache2`**  

### PHP 7.2 Packages
**`cli`** **`curl`** **`gd mysql`** **`zip`** **`xml`** **`ldap`** **`mbstring`** **`common`** **`json`** **`opcache`** **`readline`** **`intl`** **`fpm`** **`bz2`** **`mysqli`** **`pgsql`**

### Included 
* **`php.ini`**    
```ini
memory_limit = 256M
post_max_size = 32M
date.timezone = Europe/Berlin
upload_max_filesize = 32M
post_max_size = 32M
max_execution_time = 60
extension = apcu.so
extension = memcached.so
extension = redis.so
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
version: "3.1"
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
### Compose Up Environment
* Change directory to the path docker-compose.yaml lies in
> **`cd pathtoDockerComposeFIle`**  
* Compose up
> **`docker-compose up -d`**  
* Check Login https://example.org  
* How to bring down environment?
> **`docker-compose down`**  

_...f i n i s h e d_  

* Check the new certificates  
https://www.ssllabs.com/ssltest/analyze.html?d=example.org
  
_Certbot check for new certificate twice a day via_  
**`/etc/systemd/system/timers.target.wants/certbot.timer`**  
  
_Certbot timer status can be checked with_  
**`systemctl status certbot.timer`**  


### JUST IN CASE

* How to install **`docker`** on **`debian:stretch`**
```bash
sudo apt-get update
sudo apt-get install -y \
    dirmngr \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

* How to install docker-compose?
```bash
curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo docker-compose --version
```

* Make **`docker ps`** bit nicer
```bash
alias docks='docker ps --format="table {{.ID}}\t{{.Status}}\t{{.Names}}"'
```
_so, just use **`docks`** to see runnnig container, or use **`docks -a`**_  
_and may add this code to ~/.profile_

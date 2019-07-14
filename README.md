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

### One Command Line Run
```docker
docker run -d --restart=always --name myjoomla -p 8080:80 -v /dock/data/myjoomla/logs:/var/log/apache2 -v /dock/data/myjoomla/html:/var/www/html/joomla enbucm/joomla
```

### Docker-Compose
```yaml
version: '3.1'

services:

  joomla:
    image: enbucm/joomla
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

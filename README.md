# Joomla Container
_by H5.Technology_ **`[admin@h5tec.com]`**  

**`debian:stretch`** **`joomla:3.9.10`** **`php:7.2`** **`apache2`**  **``**

```Dockerfile
docker run -d \
  --restart=always \
  --name myjoomla \
  -p 8080:80 \
  -v /dock/data/myjoomla/log:/var/log/apache2 \
  -v /dock/data/myjoomla/html:/var/www/html/joomla \
  enbucm/joomla
```

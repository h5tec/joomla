# Joomla! based on Debian Stretch
FROM debian:stretch
MAINTAINER H5.Technology <admin@h5tec.com>

# Set correct environment variables.
ENV HOME /root
ENV JOOMLA_INSTALLATION_DISABLE_LOCALHOST_CHECK=1

# install and configure everything in one step
RUN apt-get update -yqq; apt-get upgrade -yqq; apt install -yqq \
    pkg-config \
    apt-transport-https \
    lsb-release \
    ca-certificates \
    wget \
    curl \
    nano \
    unzip \
    apache2 \
    net-tools \
    pkg-config \
    libbz2-dev \
    libjpeg-dev \
    libldap2-dev \
    libmemcached-dev \
    libpng-dev \
    libpq-dev \
    libzip-dev \
    libxml2-dev \
    libcurl3-openssl-dev

# install and configure php
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg; \
  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list; \
  apt-get update -yqq; \
  apt-get upgrade -yqq; \
  apt install -yqq \
    libapache2-mod-php7.2 \
    php-pear \
    php7.2 \
    php7.2-dev \
    php7.2-cli \
    php7.2-curl \
    php7.2-gd \
    php7.2-mysql \
    php7.2-zip \
    php7.2-xml \
    php7.2-ldap \
    php7.2-mbstring \
    php7.2-common \
    php7.2-json \
    php7.2-opcache \
    php7.2-readline \
    php7.2-intl \
    php7.2-fpm \
    php7.2-bz2 \
    php7.2-mysqli \
    php7.2-pgsql;\
  yes '' | pecl install -f APCu-5.1.17; \
  yes '' | pecl install -f memcached-3.1.3; \
  yes '' | pecl install -f redis-4.3.0; \
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd $(php -r 'echo ini_get("extension_dir");')/*.so | awk '/=>/ { print $3 }' | sort -u | xargs -r dpkg-query -S | cut -d: -f1 | sort -u | xargs -rt apt-mark manual; \
  a2enmod rewrite; \
  a2enmod proxy_fcgi setenvif; \
  a2enconf php7.2-fpm

# create and enable /etc/apache2/sites-available/joomla.conf -> sites-enabled
RUN rm /etc/apache2/sites-enabled/*; \
  printf "<VirtualHost *:80>\n\n" > /etc/apache2/sites-available/joomla.conf; \
  printf "  ServerAdmin webmaster@localhost\n" >> /etc/apache2/sites-available/joomla.conf; \
  printf "  DocumentRoot /var/www/html\n" >> /etc/apache2/sites-available/joomla.conf; \
  printf "  ServerName localhost\n\n" >> /etc/apache2/sites-available/joomla.conf; \
  printf "  <Directory /var/www/html>\n" >> /etc/apache2/sites-available/joomla.conf; \
  printf "    Options FollowSymLinks\n" >> /etc/apache2/sites-available/joomla.conf; \
  printf "    AllowOverride All\n" >> /etc/apache2/sites-available/joomla.conf; \
  printf "    Order allow,deny\n" >> /etc/apache2/sites-available/joomla.conf; \
  printf "    allow from all\n" >> /etc/apache2/sites-available/joomla.conf; \
  printf "  </Directory>\n\n" >> /etc/apache2/sites-available/joomla.conf; \
  printf "  ErrorLog /var/log/apache2/joomla-error_log\n" >> /etc/apache2/sites-available/joomla.conf; \
  printf "  CustomLog /var/log/apache2/joomla-access_log common\n\n" >> /etc/apache2/sites-available/joomla.conf; \
  printf "</VirtualHost>\n" >> /etc/apache2/sites-available/joomla.conf; \
  ln -s /etc/apache2/sites-available/joomla.conf /etc/apache2/sites-enabled/joomla.conf

# configure /etc/apache2/apache2.conf
RUN printf "\n<IfModule mod_env.c>\n  SetEnv HTTPS on\n</IfModule>\n\n" >> /etc/apache2/apache2.conf

# configure php.ini
RUN printf "memory_limit = 256M\n" >> /etc/php/7.2/apache2/php.ini; \
  printf "post_max_size = 32M\n" >> /etc/php/7.2/apache2/php.ini; \
  printf "date.timezone = Europe/Berlin\n" >> /etc/php/7.2/apache2/php.ini; \
  printf "upload_max_filesize = 32M\n" >> /etc/php/7.2/apache2/php.ini; \
  printf "post_max_size = 32M\n" >> /etc/php/7.2/apache2/php.ini; \
  printf "max_execution_time = 60\n" >> /etc/php/7.2/apache2/php.ini; \
  printf "extension = apcu.so\n" >> /etc/php/7.2/apache2/php.ini; \
  printf "extension = memcached.so\n" >> /etc/php/7.2/apache2/php.ini; \
  printf "extension = redis.so\n" >> /etc/php/7.2/apache2/php.ini

# download and install joomla 3.9.10
RUN wget -O joomla.zip 'https://downloads.joomla.org/cms/joomla3/3-9-10/Joomla_3-9-10-Stable-Full_Package.zip?format=zip'; \
  rm -rf /var/www/html/*; \
  unzip joomla.zip -d /var/www/html; \
  chown -R www-data:www-data /var/www/html; \
  chmod -R 755 /var/www/html; \
  rm joomla.zip

# clean up scotti
RUN apt-get clean; \
  rm -rf /var/lib/apt/lists/*; \
  rm -rf /tmp/* /var/tmp/*

VOLUME [ "/var/www/html", "/var/log/apache2" ]

EXPOSE 80

CMD apache2ctl -D FOREGROUND

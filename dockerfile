FROM ubuntu:16.04

# Maintainer
LABEL maintainer="Lucas Cardial <luccascardial@gmail.com>"
ENV NGINX_VERSION 1.9.3-1~jessie
RUN apt-get update

RUN apt-get install -y software-properties-common
RUN apt-get install -y python-software-properties
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update
RUN command apt-get install -y nginx php7.2 php7.2-fpm php7.2-dev curl git php-pear && apt-get clean

# NGINX
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
VOLUME ["/var/cache/nginx"]
RUN rm /etc/nginx/sites-available/default
ADD ./default /etc/nginx/sites-available/default

# COMPOSER
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php && rm composer-setup.php && mv composer.phar /usr/local/bin/composer && chmod a+x /usr/local/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1

# BUILD
WORKDIR /var/www/html
RUN pecl install mongodb

# RUN curl https://raw.githubusercontent.com/docker-library/php/master/docker-php-ext-enable --output docker-php-ext-enable
# RUN mv docker-php-ext-enable /bin/docker-php-ext-enable
# RUN chmod 744 /bin/docker-php-ext-enable

# RUN chown -R $USER:www-data /var/www/html/storage
# RUN chown -R $USER:www-data /var/www/html/bootstrap/cache
# RUN chmod -R 777 /var/www/html/storage
EXPOSE 80 443
RUN echo "extension=mongodb.so" > /etc/php/7.2/fpm/conf.d/30-mongodb.ini
RUN echo "extension=mongodb.so" > /etc/php/7.2/cli/conf.d/30-mongodb.ini
CMD chmod -R 777 /var/www/html/storage && service php7.2-fpm start && nginx -g "daemon off;" 
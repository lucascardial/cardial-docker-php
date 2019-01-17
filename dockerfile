FROM ubuntu:16.04

# Maintainer
LABEL maintainer="Lucas Cardial <luccascardial@gmail.com>"
ENV NGINX_VERSION 1.9.3-1~jessie
RUN apt-get update

RUN apt-get install -y software-properties-common
RUN apt-get install -y python-software-properties
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update

RUN apt-get update && apt-get install -y nginx php7.2-fpm curl git && apt-get clean

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
#RUN git clone https://<seu usuario>:<sua senha>@bitbucket.org/<usuario dono do repositório>/<nome do repositório> <nome da aplicação>

EXPOSE 80 443
CMD service php7.2-fpm start && nginx -g "daemon off;"
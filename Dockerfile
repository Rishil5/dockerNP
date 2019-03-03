FROM php:7.1.13-fpm

ENV php_conf /usr/local/etc/php/php.ini
ENV fpm_conf /usr/local/etc/php/php-fpm.conf
ENV fpm_conf_dir /usr/local/etc/php-fpm.d/

RUN apt-get update
RUN apt-get install -y autoconf pkg-config libssl-dev
RUN pecl install mongodb
RUN docker-php-ext-install bcmath
RUN echo "extension=mongodb.so" >> /usr/local/etc/php/conf.d/mongodb.ini

RUN apt-get update
RUN apt-get install -y nginx supervisor cron

RUN docker-php-ext-install zip

RUN mkdir -p /code/public

RUN useradd --no-create-home nginx

# tweak php-fpm config
COPY php/php.ini ${php_conf}
COPY php/www.conf.default ${fpm_conf_dir}/www.conf
COPY php/pools/pool-1.conf ${fpm_conf_dir}/pool-1.conf
COPY php/pools/pool-2.conf ${fpm_conf_dir}/pool-2.conf
COPY php/pools/pool-3.conf ${fpm_conf_dir}/pool-3.conf
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/php.conf /etc/nginx/php.conf
COPY nginx/host.conf /etc/nginx/conf.d/default.conf

# add cron runner script
COPY cron.sh /cron.sh

COPY supervisord.conf /etc/supervisor/supervisord.conf

WORKDIR /code/public

EXPOSE 443 80

CMD /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf

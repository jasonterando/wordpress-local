FROM php:7.3-apache
RUN apt-get update \
    && apt-get install -y imagemagick libsodium-dev libmagickwand-dev zlib1g-dev net-tools iputils-ping net-tools --no-install-recommends \
    && apt-get clean

RUN docker-php-ext-install exif mysqli
RUN pecl install xdebug imagick \
    && docker-php-ext-enable xdebug imagick
RUN a2enmod rewrite

COPY ./setup/docker-site/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod 777 /usr/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["apache2-foreground"]

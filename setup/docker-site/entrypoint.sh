#!/bin/bash

# Allow Wordpress to write to wp-content directory
chown -R www-data:www-data /var/www/html/wp-content/
chmod -R 777 /var/www/html/wp-content/

# Creates a host.docker.internal HOST entry for Linux Docker
# (this gets created "automatically" for Docker Windows and Mac)
# From https://dev.to/bufferings/access-host-from-a-docker-container-4099
HOST_DOMAIN="host.docker.internal"
ping -q -c1 $HOST_DOMAIN > /dev/null 2>&1
if [ $? -ne 0 ]; then
    HOST_IP=$(route | awk 'FNR==3 {print $2}')
    echo -e "$HOST_IP\t$HOST_DOMAIN" >> /etc/hosts
fi

# Update WordPress configuration to direct datatbase to local container, set debug to true
if [ ! -f "/var/www/html/wp-config.php.bak" ]; then 
    echo "Updating wp-config.php for local debugging - copying backup to wp-config.php.bak"
    sed -i.bak "s/define.*DB_HOST.*;/define( 'DB_HOST', 'db' );/" wp-config.php
    sed -i "s/define.*WP_DEBUG.*;/define( 'WP_DEBUG', true );/" wp-config.php
fi

# Copy in original PHP docker-php-entrypoint content
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"
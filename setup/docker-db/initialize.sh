#!/bin/bash

# Grab the database name, user and password from wp-config
dbname=`gawk 'match($0, /define\(\s+[\x27"]DB_NAME[\x27"]\s*,\s*[\x27"](.*)[\x27"]/, a) { print a[1] }' /tmp/wordpress/wp-config.php`
dbuser=`gawk 'match($0, /define\(\s+[\x27"]DB_USER[\x27"]\s*,\s*[\x27"](.*)[\x27"]/, a) { print a[1] }' /tmp/wordpress/wp-config.php`
dbpassword=`gawk 'match($0, /define\(\s+[\x27"]DB_PASSWORD[\x27"]\s*,\s*[\x27"](.*)[\x27"]/, a) { print a[1] }' /tmp/wordpress/wp-config.php`
if test -z "$dbname" 
then
    echo "ERROR: Unable to parse DB_NAME from wp-config.php"
    exit -1
fi
if test -z "$dbuser" 
then
    echo "ERROR: Unable to parse DB_USER from wp-config.php"
    exit -1
fi
if test -z "$dbpassword" 
then
    echo "ERROR: Unable to parse DB_PASSWORD from wp-config.php"
    exit -1
fi

if [ ! -f "/tmp/setup/backup.sql" ]; then 
    echo "ERROR: Unable to access backup SQL backup file /setup/backup.sql"
    exit -2
fi

# Grab the site domain from the SQL backup
domain=`gawk 'match($0, /siteurl[\047", ]*([^\047"]*)/, a)  {print a[1]}' /tmp/setup/backup.sql;`
if test -z "$domain" 
then
    echo "ERROR: Unable to parse domain from SQL backup"
    exit -1
fi

echo -n "$domain" > /tmp/setup/domain.bak

echo "Changing site Domain from $domain to http://localhost"
sed 's,'"$domain"',http://localhost,' /tmp/setup/backup.sql > /tmp/setup/backup-local.sql

echo "DB_NAME: $dbname"
echo "DB_USER: $dbuser"
echo "DB_PASSWORD: $dbpassword"
echo "root password: $MYSQL_ROOT_PASSWORD"

echo "Creating WordPress Database"
"${mysql[@]}" <<-EOSQL
    GRANT ALL on *.* to 'root'@'%' identified by '$MYSQL_ROOT_PASSWORD' with grant option;
    CREATE DATABASE IF NOT EXISTS \`$dbname\`;
    CREATE USER '$dbuser'@'%' IDENTIFIED BY '$dbpassword';
    GRANT ALL ON \`$dbname\`.* TO '$dbuser'@'%';
    USE $dbname;
    SOURCE /tmp/setup/backup-local.sql;
EOSQL

export MYSQL_DATABASE=$dbname


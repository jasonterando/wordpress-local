FROM mysql/mysql-server:5.7

# Set up our script to initialize Wordpress database from a backup
COPY ./setup/docker-db/initialize.sh /docker-entrypoint-initdb.d/initialize.sh
RUN chmod +x /docker-entrypoint-initdb.d/initialize.sh

ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK CMD /healthcheck.sh
EXPOSE 3306 33060
CMD ["mysqld"]
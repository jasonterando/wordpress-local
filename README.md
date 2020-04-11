# Debugging WordPress locally

This is a project to assist in troubleshooting hosted WordPress sites by facilitating copying a hosted WordPress site locally.  It includes support for using Microsoft Visual Code for debugging via XDEBUG, but you can use any editor you want. 

In the name of all that is Good, do *not use this to host sites in production*! 

This documentation is not a tutorial on Docker, Docker Compose, PHP or Microsoft Visual Code.  It assumes you have these installed and some level of working knowledge.

Requirements:

1. Your WordPress host has phpMyAdmin that you can use to make a database backup file
2. You can copy your site files locally (via FTP, SFTP, SCP, etc.)

This is a one-way trip.  Migrating changes back to the host is not supported (there is a lot that go wrong).  If you do want to run with scissors and try something like this, see the database notes below.

## Quick Start

1. Backup your database to a SQL file ("Quick" export method is fine - i.e. schema and data), and save a copy of the backup file to `setup/backup.sql` (it must be called exactly that).
2. Place your sites files in the `site` directory
3. Run `docker-compose up``
4. Browse to `http://localhost` for your WordPress site, `http://localhost:8080` for phpMyAdmin.

If it doesn't work, keep reading :)

## Operation

This project sets up a Docker Compose application which includes three containers:

1. MySQL (version 5.7)
2. PHP (PHP 7.3 - Apache)
3. phpMyAdmin

WordPress stores some of its settings in code (`wp-content.php`) and some settings in the database.  For some reason, PHP developers love storing settings in code files.  WordPress stores things like database connectivity settings in `wp-content.php` but values like the site domain and name in the database.  

This project performs the following steps to transplant a hosted WordPress site locally.

1. It replaces references to the site domain in the database backup file to `http://localhost` (both for site configuration and for links)
2. It restores the site database to the database named in `wp-content.php`, along with the specified name and password.
3. It updates the `wp-content` file to read the database from the local database container, and turn on debugging
4. Installs PHP extensions for mysqli and and xdebug, and installs the Apache rewrite module
5. Creates the `host.docker.internal` entry for Linux users to enable XDEBUG connections to the editor
5. Sets up the Visual Code task for debugging using XDEBUG

## Preparation

1. Export your WordPress database as a SQL file using phpMyAdmin. Other tools should work, as long as they export all schema and data information.  Save a copy of the backup file to `setup/backup.sql` in this project (to that exact dierctory, with that exact name).  If you're not using phpMyAdmin, the most likely thing to go wrong will be the AWK command to identify the domain name in the database (see `setup/docker-db/initialize.sh`).

2. Copy your WordPress site files to the `site` directory

3. The Docker files for this project leverage the official Docker Hub images for MySQL 5.7 and PHP/Apache 7.3.  If you need different versions, update the Docker files in `setup/docker-db` and `setup/docker-site` as desired.

4. The Docker Compose file (`./docker-compose.yml`) exposes the WordPress site on port 80, and phpMyAdmin on 8080.  If these ports are not available, you can update `docker-compolse.yml` as desired.

5. If you are going to use Microsoft Visual Code, make sure you have the [PHP Debug](https://marketplace.visualstudio.com/items?itemName=felixfbecker.php-debug]) extension installed.  Open this project folder in Visual Code (you should see a "Debug WordPress" debug configuration).

## Notes

### Database

If you want to "start over" from the backup, delete all files in the `db` folder.  Note that the MySQL Docker container creates the files using root, so that you will have to escalate using `sudo`/`su` to remove them.

Also, if you rebuild the containers after the database is created, you may see an error like this:

```
ERROR: Couldn't connect to Docker daemon at http+docker://localunixsocket - is it running?
```

This is a "helpful" Docker Complse message that has nothing to do with daemon connectivity.  To see the "real" problem, you can run Docker build directly, and you'll see there's a permission issue with the `db` folder (Docker build apparently scans all directories in the build context, regardless if they are used or not).  Since the MySQL container sets up the database as root, you'll need to do one of the following:

1. `chown` all files (recursively) in the `db` folder to yourself so that Docker build will run (this doesn't appear to affect the operation of the MySQL container) -- `sudo chown -R yourname: yourname db`
2. Run `docker-compose` as root (not a good idea)
3. Get rid of the `db` folder  and start over

In the future, hopefully either MySQL won't use root, or Docker will update *build* to not check directories it isn't using.

Finally, there is a script in `/setup` called `restore.sh` that reveres the replacement of the domain in the database backup file.  If you to try and restore your site's production database with what you have locally, you can do something like this:

1. Backup your local database to `./setup/restore-local.sql`
2. Run the script `./setup/restore.sh` (Windows guys, you can use WSL)
3. The file `./setup/restore.sql` should be ready to restore to your host via phpMyAdmin.  Make sure you do another backup before restoring this file
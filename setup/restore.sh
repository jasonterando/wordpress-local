#!/bin/bash
# Restore domain in SQL restore-local.sql file back to original values, save to restore.sql
sed 's,http://localhost,'"`cat ./domain.bak`"',' ./restore-local.sql > ./restore.sql

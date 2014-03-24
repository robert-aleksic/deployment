mkdir /var/www/shared/backups
zip -r /var/www/shared/backups/backup-`date '+%Y-%m-%d-%H:%M:%S'` /var/www/current/public/uploads/ /var/www/shared/*.sqlite3

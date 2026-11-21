# Week 4 – Linux Server Backup

## Servers

- Server 1: Primary web and database server
- Server 2: Replica database server and Week 4 website

## Backup System

Website files are backed up hourly from Server 1 to Server 2 using rsync.

MariaDB databases are backed up daily using mariadb-dump. Backup files are compressed and transferred to Server 2.

Backups are stored outside the public web directory.

## Database Replication

MariaDB replication transfers database changes continuously from Server 1 to Server 2.

Server 2 is configured in read-only mode for ordinary database writes.

## Repository Contents

- `backup_www.sh` – Website backup script
- `backup_db.sh` – Database backup script
- `crontab.txt` – Original cron configuration
- `replication_config.txt` – MariaDB replication configuration
- `test_results.txt` – Project test results
- `.gitignore` – Files excluded from version control


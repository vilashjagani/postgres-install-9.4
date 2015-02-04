#!/bin/bash
/usrdata/pgsql/bin/psql -p 15000 -c "CREATE USER replicator REPLICATION LOGIN ENCRYPTED PASSWORD 'replicator';"
/usrdata/pgsql/bin/psql -p 15000 -c "CREATE USER pgpool LOGIN ENCRYPTED PASSWORD 'pgpool';"
mkdir /usrdata/pgsql/backup
/usrdata/pgsql/bin/psql -p 15000 -c "select pg_start_backup('base_backup');"
tar -cvf backup/base_backup.tar --exclude=pg_xlog --exclude=postmaster.pid  data
/usrdata/pgsql/bin/psql -p 15000 -c "select pg_stop_backup();"

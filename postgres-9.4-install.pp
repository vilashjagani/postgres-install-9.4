           exec {"apt-get":
                  command => "dpkg --add-architecture i386",
                  path =>"/bin:/usr/bin",
                } ->
            exec {"apt-get-update":
                    command => "apt-get update",
                    path =>"/bin:/usr/bin",
                 } ->
            package { [ "flex", "bison", "build-essential", "libreadline6-dev", "zlib1g-dev", "libossp-uuid-dev", "libssl-dev:i386", "libssl-dev", "gcc" ]: 
                      ensure => "present",
                    } ->
            file    {"/usrdata/pgsql":
                      ensure => "directory",
                    } ->
            user {"postgres":
                  ensure     => "present",
                  managehome => true,
                  home => '/usrdata/pgsql',
                  shell => '/bin/bash',
                  password => '$1$cjvVjeZF$D3cgBF3e2gBFTGxZW8F440',
                 } ->
           exec {"postgress-install":
                  command => "mkdir -p /usrdata/pgsql;mkdir /usrdata/source;wget -e use_proxy=yes -e https_proxy=10.135.80.164:8678 -O /usrdata/source/postgresql-9.4.0.tar.bz2  https://ftp.postgresql.org/pub/source/v9.4.0/postgresql-9.4.0.tar.bz2;cd /usrdata/source;tar jxvf postgresql-9.4.0.tar.bz2;cd /usrdata/source/postgresql-9.4.0;./configure --prefix=/usrdata/pgsql --with-ossp-uuid --with-openssl; make && make install;cd /usrdata/source/postgresql-9.4.0/contrib;make && make install;mkdir -p /usrdata/pgsql/logs;chown -R postgres:postgres /usrdata/pgsql;su postgres -c '/usrdata/pgsql/bin/initdb --pgdata=/usrdata/pgsql/data --encoding=UTF8';",
                  path =>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                } ->

        exec {" postgres-setup":
              command => "echo \"listen_addresses = '*'\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"port = 15000\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"wal_level = hot_standby\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"hot_standby = on\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"max_wal_senders = 3\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"wal_keep_segments = 3\">> /usrdata/pgsql/data/postgresql.conf;
                          echo \"checkpoint_segments = 8\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"max_connections=300\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"shared_buffers = 8192MB\"  >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"temp_buffers = 128MB\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"max_prepared_transactions = 20\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"log_destination = 'csvlog'\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"logging_collector = on\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"log_directory = '/usrdata/pgsql/logs'\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"log_filename = 'postgresql-%a.log'\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"autovacuum = on\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"autovacuum_max_workers = 3\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"autovacuum_naptime = 10080min\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"autovacuum_vacuum_threshold = 1000\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"#host replication replicator  MASTER-SRV-IP/32 md5\" >> /usrdata/pgsql/data/pg_hba.conf;
                          echo \"host replication replicator  192.168.59.35/32 md5\" >> /usrdata/pgsql/data/pg_hba.conf;
                          echo \"#host replication replicator  SLAVE-SRV-IP/32 md5\" >> /usrdata/pgsql/data/pg_hba.conf;
                          echo \"host replication replicator  192.168.59.30/32 md5\" >> /usrdata/pgsql/data/pg_hba.conf;
                          echo \"#host all replicator  PGPOOL-1-IP/32 trust\" >> /usrdata/pgsql/data/pg_hba.conf;
                          echo \"host all replicator  192.168.59.38/32 trust\" >> /usrdata/pgsql/data/pg_hba.conf;
                          echo \"#host all replicator  PGPOOL-2-IP/32 trust\" >> /usrdata/pgsql/data/pg_hba.conf;
                          echo \"host all replicator  192.168.59.51/32 trust\" >> /usrdata/pgsql/data/pg_hba.conf;
                          echo \"#host all postgres  PGPOOL-1-IP/32 trust\" >> /usrdata/pgsql/data/pg_hba.conf;
                          echo \"host all postgres  192.168.59.38/32 trust\" >> /usrdata/pgsql/data/pg_hba.conf;
                          echo \"#host all postgres  PGPOOL-2-IP/32 trust\" >> /usrdata/pgsql/data/pg_hba.conf;
                          echo \"host all postgres  192.168.59.51/32 trust\" >> /usrdata/pgsql/data/pg_hba.conf;
                          echo \"#host all pgpool  PGPOOL-1-IP/32 trust\" >> /usrdata/pgsql/data/pg_hba.conf;
                          echo \"host all pgpool  192.168.59.38/32 trust\" >> /usrdata/pgsql/data/pg_hba.conf;
                          echo \"#host all pgpool  PGPOOL-2-IP/32 trust\" >> /usrdata/pgsql/data/pg_hba.conf;
                          echo \"host all pgpool  192.168.59.51/32 trust\" >> /usrdata/pgsql/data/pg_hba.conf;",
               path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
             } ->
        
      exec { "post-script-dwn":
        command => "wget -e use_proxy=yes -e https_proxy=10.135.80.164:8678 -O /etc/init.d/postgresql https://github.com/vilashjagani/postgres-install-9.4/raw/master/postgresql;
                  chmod 755 /etc/init.d/postgresql",
        path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
           } ->
      exec { "postgres-passwdless":
             command => "wget -e use_proxy=yes -e https_proxy=10.135.80.164:8678 -O /usrdata/pgsql/ssh.tar https://github.com/vilashjagani/postgres-install-9.4/raw/master/ssh.tar;
                        cd /usrdata/pgsql;
                        tar xvf ssh.tar; 
                        chown -R postgres:postgres .ssh",
             path => /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            } ->
      exec { "slave-scrip:"
             command => "wget -e use_proxy=yes -e https_proxy=10.135.80.164:8678 -O /usr/bin/slave.sh https://github.com/vilashjagani/postgres-install-9.4/raw/master/slave.sh;
                        chmod 755 /usr/bin/slave.sh;
                        cp /usr/bin/slave.sh /usrdata/pgsql/bin/;
                        chown postgres:postgres /usrdata/pgsql/bin/slave.sh",
             path => /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
           } ->
       exec { "post-psql-script":
             command => "wget  -e use_proxy=yes -e https_proxy=10.135.80.164:8678 -O /root/post-master-potgres.sh  https://github.com/vilashjagani/postgres-install-9.4/raw/master/post-master-potgres.sh",
             path => /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            }


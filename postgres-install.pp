 exec {"apt-get":
                  command => "apt-get update",
                  path =>"/bin:/usr/bin",
                } ->
            package { [ "flex", "bison", "build-essential", "libreadline6-dev", "zlib1g-dev", "libossp-uuid-dev" ]:
                      ensure => "installed",
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
                  command => "mkdir -p /usrdata/pgsql;mkdir /usrdata/source;wget -e use_proxy=yes -e https_proxy=10.135.80.164:8678 -O /usrdata/source/postgresql-9.3.5.
tar.gz  https://ftp.postgresql.org/pub/source/v9.3.5/postgresql-9.3.5.tar.gz;cd /usrdata/source;tar zxvf postgresql-9.3.5.tar.gz;cd /usrdata/source/postgresql-9.3.5;./c
onfigure --prefix=/usrdata/pgsql; make && make install;cd /usrdata/source/postgresql-9.3.5/contrib;make && make install;mkdir -p /usrdata/pgsql/logs;chown -R postgres:p
ostgres /usrdata/pgsql;su postgres -c '/usrdata/pgsql/bin/initdb --pgdata=/usrdata/pgsql/data --encoding=UTF8';",
                  path =>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                } ->

        exec {" postgres-setup":
              command => "echo \"listen_addresses = '*'\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"port = 15000\" >> /usrdata/pgsql/data/postgresql.conf;
                          echo \"wal_level = hot_standby\" >> /usrdata/pgsql/data/postgresql.conf;
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
                          echo \"autovacuum_vacuum_threshold = 1000\" >> /usrdata/pgsql/data/postgresql.conf",
               path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
             }

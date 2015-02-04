#!/bin/bash
echo "Enter Master server IP address or FQDN name:"
read MIP
echo "Enter Slave server IP address or FQDN name:"
read SIP
#echo $MIP
#echo $SIP
CIP=`/sbin/ifconfig| grep "inet " | grep -v 127.0.0.1 | awk {'print $2'} | sed -e's/addr://g'`
echo $CIP
if [ $SIP == $CIP ]
then
   echo " This is Slave server"
   echo "Take backup from master runing and restore here"
   tar -cf /usrdata/pgsql/data-bkup-`date +"%d-%m-20%y.tar"` /usrdata/pgsql/data
   ssh $MIP  /usrdata/pgsql/bin/psql -p 15000 <<'__END__'
   SELECT pg_start_backup('replibackup');
__END__
   ssh $MIP 'cd /usrdata/pgsql/; tar cf /tmp/data-bkp.tar data'
   ssh $MIP '/usrdata/pgsql/bin/psql -p 15000 -c "SELECT pg_stop_backup();"'
   scp  postgres@$MIP:/tmp/data-bkp.tar /usrdata/pgsql/
   ###### Before extract data check postgres service is runiing if runing ,stop it ####
   	STR=`ps -ef | grep postgres | grep checkpointer | grep -v grep | awk {'print $NF'}`
   	if [ -z $STR ]
    	then
        echo " service is not runing ..... so extract data"
         cd /usrdata/pgsql/
         rm -rf data
         tar xf data-bkp.tar
    
         else
         echo "postgres service is running... stop it"
        /usrdata/pgsql/bin/pg_ctl -D /usrdata/pgsql/data -l logfile stop
         cd /usrdata/pgsql/
         rm -rf data
         tar xf data-bkp.tar
    	fi

   
   ###change pg_hba_conf file
   fin=`cat /usrdata/pgsql/data/pg_hba.conf | grep $MIP`
     if [ -z "$fin" ]
     then
          echo "host    replication    replicator  $MIP/32    md5" >> /usrdata/pgsql/data/pg_hba.conf
     else
         echo "There is already $MIP in pg-hba.conf"
     fi
   ##### changes postgres.conf file #####
    fin1=`cat /usrdata/pgsql/data/postgresql.conf | grep "hot_standby = on" | grep -v "#"`
    if [ -z "$fin1" ]
    then
       echo "hot_standby = on" >> /usrdata/pgsql/data/postgresql.conf
        sed -i 's/hot_standby\ \=\ off/\#hot_standby\ \=\ off/g' /usrdata/pgsql/data/postgresql.conf
    else
    echo "there is already hot_standby entry in postgresql.conf"    
   fi
   ######## create recovery.conf #####
   rm -rf /usrdata/pgsql/data/recovery.done
   echo "primary_conninfo = 'host= $MIP port=15000 user=replicator password=replicator'" > /usrdata/pgsql/data/recovery.conf
   echo "trigger_file = '/tmp/postgresql.trigger'" >> /usrdata/pgsql/data/recovery.conf
   echo "standby_mode = 'on'" >> /usrdata/pgsql/data/recovery.conf
  ####### start service #######
  /usrdata/pgsql/bin/pg_ctl -D /usrdata/pgsql/data -l logfile start 
else
   echo " this is not slave server"
fi

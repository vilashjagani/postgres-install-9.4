# postgres-installation
1)   install puppet Agent on server

       wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
 
       dpkg -i puppetlabs-release-trusty.deb
 
       apt-get install puppet
       Add Proxy setting in puppet
       vi /etc/puppet/puppet.conf
       
       http_proxy_host = x.x.x.x
       
       http_proxy_port = port-number 
       
        https_proxy_host = x.x.x.x
        
        https_proxy_port = port-number
       
2) Download postgres-9.4-install.pp puppet manifest and install 
      
       wget https://github.com/vilashjagani/postgres-install-9.4/raw/master/postgres-9.4-install.pp
      
       puppet apply postgres-9.4-install.pp
      
       This puppet will install postgres-9.4 with SSL and contrib features
       This is also make postgres user access keybased without password which is required by pgpool and master/slave postgres.
       
        
        if you want to configure postgres as MASTER server run follwoing script first time after runing puppet manifest. 
           first start service 
          /etc/init.d/postgres start
          #bash /root/post-master-potgres.sh
          
          chnage IP addrress of MASTER,SLAVE postgres servers and PGPOOL-1 and PGPOOL-2 servers IP as per your setup in               following file
          #vi /usrdata/pgsql/data/pg_hba.conf file
          
         if you want to configure postgres server as SLAVE server run following script.
         
                   # su - postgres
                   postgres@ps2:~$/usr/bin/slave.sh
                   
                   Enter IP address of MASTER and SLAVE servers.
                   start postgress service
                   /etc/init.d/postgres start
         
        
      
      
      


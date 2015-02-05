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
      
      
      


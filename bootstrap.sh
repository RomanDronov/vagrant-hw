#!/usr/bin/env bash
 
apt-get update
 
# install apache
apt-get install -q -y apache2
sudo apt-get install -q -y python3
#sudo apt-get install libapache2-mod-python
sudo apt-get install -q -y python3-pip
sudo apt-get install -q -y python-pip
sudo apt-get install -q -y apache2 libapache2-mod-wsgi-py3
sudo apt-get install -q -y libapache2-mod-wsgi
sudo apt-get install -q -y apache2 openssl
sudo apt-get install -q -y ufw
echo y |sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 2222/tcp
sudo ufw allow 80,443/tcp
sudo ufw allow OpenSSH
sudo a2enconf wsgi
#sudo a2enmod cgi

# /vagrant is shared by default
# symlink that to /var/www
# this will be the pubic root of the site

# configuration files live at /etc/apache2/
sudo mkdir /etc/apache2/sites-available/default
mkdir -p /var/www/test.com/public_html
mkdir -p /var/www/test.com/cgi-bin
mkdir -p /etc/apache2/modules


################################################################################

# Enable SSI following (mostly) the directions here:
# https://help.ubuntu.com/community/ServerSideIncludes
#ssl cert
domain='testcom'
commonname='127.0.0.1'
country=DE
state=Berlin
locality=Deutch
organization=example.com
organizationalunit=INC
email=admin@example.com

if [ -z "$domain" ]
then
    echo "Argument not present."
    echo "Useage $0 [common name]"

    exit 99
fi

echo "Generating key request for $domain"
#Generate a key
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/testcom.key -out /etc/ssl/certs/testcom.crt \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

echo "---------------------------"
echo "-----Below is your CSR-----"
echo "---------------------------"
echo
sudo cat /etc/ssl/certs/$domain.crt

echo
echo "---------------------------"
echo "-----Below is your Key-----"
echo "---------------------------"
echo
sudo cat /etc/ssl/private/$domain.key
# Add the Includes module
a2enmod include
# Add Includes, AddType and AddOutputFilter directives
mv /etc/apache2/sites-available/default /etc/apache2/sites-available/default.bak
cp /vagrant/default /etc/apache2/sites-available/default
cp /vagrant/conf/example.com.conf /etc/apache2/sites-available
cp /vagrant/conf/test.com.conf /etc/apache2/sites-available
cp /vagrant/www/html/index.html /var/www/html
#cp /vagrant/www/test.com/index.html /var/www/test.com
sudo cp /vagrant/ssl/default-ssl.conf /etc/apache2/sites-available
#cp /vagrant/www/test.com/cgi-bin/cgi-script.py /var/www/test.com/cgi-bin
cp /vagrant/www/test.com/index.py /var/www/test.com
cp /vagrant/www/test.com/index.wsgi /var/www/test.com
#cp /vagrant/www/test.com/index.py /var/www/test.com/cgi-bin
#sudo chmod 755 /var/www/testy.com/index.py
#sudo chmod 755 /var/www/test.com/cgi-bin/index.py
#sudo chmod 755 /var/www/test.com/cgi-bin/cgi-script.py

# To allow includes in index pages
mv /etc/apache2/mods-available/dir.conf /etc/apache2/mods-available/dir.conf.bak
cp /vagrant/dir.conf /etc/apache2/mods-available/dir.conf

# restart apache2
apachectl -k graceful
sudo a2enmod ssl
sudo a2ensite example.com.conf
sudo a2ensite test.com.conf
sudo a2dissite 000-default.conf
chgrp www-data /var/www/test.com
chmod g+w /var/www/test.com
cd /etc/apache2
echo 'LoadModule wsgi_module modules/mod_wsgi.so' | sudo tee -a  apache2.conf
cd /etc/apache2/conf-available/
echo "SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
SSLHonorCipherOrder On
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the 'preload' directive if you understand the implications.
# Header always set Strict-Transport-Security 'max-age=63072000; includeSubDomains; preload'
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
# Requires Apache >= 2.4
SSLCompression off
SSLUseStapling on
SSLStaplingCache 'shmcb:logs/stapling-cache(150000)'
# Requires Apache >= 2.4.11" | sudo tee ssl-params.conf
cd /etc/ufw/applications.d/
echo '[Apache]
title=Web Server
description=Apache v2 is the next generation of the omnipresent Apache web server.
ports=80/tcp

[Apache Secure]
title=Web Server (HTTPS)
description=Apache v2 is the next generation of the omnipresent Apache web server.
ports=443/tcp

[Apache Full]
title=Web Server (HTTP,HTTPS)
description=Apache v2 is the next generation of the omnipresent Apache web server.
ports=80,443/tcp' | sudo tee apache2-utils.ufw.profile
sudo ufw allow 'Apache Full'
sudo a2enmod ssl
sudo a2enmod headers
sudo a2ensite default-ssl
sudo a2enconf ssl-params
sudo apache2ctl configtest
#cd /vagrant/www/test.com
#python3 -m http.server --cgip > /dev/null 2>&1
sudo systemctl restart apache2
journalctl -xn
# smoke test
# open a brower to http://127.0.0.1:8080 to test

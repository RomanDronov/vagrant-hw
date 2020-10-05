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
libapache2-mod-wsgi
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

# Add the Includes module
a2enmod include
#ssl cert
domain=$1
commonname=$domain
country=GB
state=Nottingham
locality=Nottinghamshire
organization=example.com
organizationalunit=IT
email=administrator@jamescoyle.net

if [ -z "$domain" ]
then
    echo "Argument not present."
    echo "Useage $0 [common name]"

    exit 99
fi

echo "Generating key request for $domain"

#Generate a key
openssl genrsa -des3 -passout pass:$password -out $domain.key 2048 -noout

#Create the request
echo "Creating CSR"
openssl req -new -key $domain.key -out $domain.csr -passin pass:$password \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

echo "---------------------------"
echo "-----Below is your CSR-----"
echo "---------------------------"
echo
cat $domain.csr

echo
echo "---------------------------"
echo "-----Below is your Key-----"
echo "---------------------------"
echo
cat $domain.key

# Add Includes, AddType and AddOutputFilter directives
mv /etc/apache2/sites-available/default /etc/apache2/sites-available/default.bak
cp /vagrant/default /etc/apache2/sites-available/default
cp /vagrant/conf/example.com.conf /etc/apache2/sites-available
cp /vagrant/conf/test.com.conf /etc/apache2/sites-available
cp /vagrant/www/html/index.html /var/www/html
#cp /vagrant/www/test.com/index.html /var/www/test.com
cp /vagrant/www/test.com/cgi-bin/cgi-script.py /var/www/test.com/cgi-bin
cp /vagrant/www/test.com/index.py /var/www/test.com
cp /vagrant/www/test.com/index.py /var/www/test.com/cgi-bin
sudo chmod 755 /var/www/test.com/index.py
sudo chmod 755 /var/www/test.com/cgi-bin/index.py
sudo chmod 755 /var/www/test.com/cgi-bin/cgi-script.py

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
#cd /vagrant/www/test.com
#python3 -m http.server --cgip > /dev/null 2>&1
sudo systemctl restart apache2
journalctl -xn
# smoke test
# open a brower to http://127.0.0.1:8080 to test

#!/usr/bin/env bash
 
apt-get update
 
# install apache
apt-get install -q -y apache2

# /vagrant is shared by default
# symlink that to /var/www
# this will be the pubic root of the site

# configuration files live at /etc/apache2/
sudo mkdir /etc/apache2/sites-available/default
mkdir -p /var/www/test.com/public_html


################################################################################

# Enable SSI following (mostly) the directions here:
# https://help.ubuntu.com/community/ServerSideIncludes

# Add the Includes module
a2enmod include

# Add Includes, AddType and AddOutputFilter directives
mv /etc/apache2/sites-available/default /etc/apache2/sites-available/default.bak
cp /vagrant/default /etc/apache2/sites-available/default
cp /vagrant/conf/example.com.conf /etc/apache2/sites-available
cp /vagrant/conf/test.com.conf /etc/apache2/sites-available
cp /vagrant/www/html/index.html /var/www/html
cp /vagrant/www/test.com/index.html /var/www/test.com


# To allow includes in index pages
mv /etc/apache2/mods-available/dir.conf /etc/apache2/mods-available/dir.conf.bak
cp /vagrant/dir.conf /etc/apache2/mods-available/dir.conf

# restart apache2
apachectl -k graceful
sudo a2enmod ssl
sudo a2ensite example.com.conf
sudo a2ensite test.com.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
# smoke test
# open a brower to http://127.0.0.1:8080 to test

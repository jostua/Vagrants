#!/usr/bin/env bash

# From Creating a Vagrant Box

echo "export PS1='laravel:\w\$ '" >> .bashrc
ln -s /vagrant/projects
cat << EOF | sudo tee -a /etc/motd.tail
***************************************

Welcome to trusty64 Vagrant Box

For Laravel development

***************************************
EOF

sudo apt-get update
sudo apt-get install -y python-software-properties build-essential
sudo add-apt-repository -y ppa:ondrej/php5
sudo apt-get update
sudo apt-get install -y git-core subversion curl php5-cli php5-curl \
 php5-mcrypt php5-gd

### From Installing Composer

curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

### From Installing MySQL

sudo debconf-set-selections <<< 'mysql-server \
 mysql-server/root-password password root'
sudo debconf-set-selections <<< 'mysql-server \
 mysql-server/root_password_again password root'
sudo apt-get install -y php5-mysql mysql-server

cat << EOF | sudo tee -a /etc/mysql/conf.d/default_engine.cnf
[mysqld]
default-storage-engine = MyISAM
EOF

sudo service mysql restart

### From Installing Apache

sudo apt-get install -y apache2 libapache2-mod-php5
sudo a2enmod rewrite
sudo service apache2 restart

echo "You've been provisioned"
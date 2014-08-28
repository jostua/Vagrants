#!/usr/bin/env bash

# Prepare Environment
# -------------------
# Create user bin folder
mkdir $HOME/bin

# Re-source profile to include $HOME/bin in PATH
source .profile

# Add www-data to the vagrant user
usermod -a -G vagrant www-data


# Update the box
# --------------
# Downloads the package lists from the repositories
# and "updates" them to get information on the newest
# versions of packages and their dependencies

apt-get update

# Install Vim
apt-get install -y vim

# Apache
# ------
# Install
apt-get install -y apache2

# PHP 5.4
# -------
apt-get install -y libapache2-mod-php5
# Add add-apt-repository binary
apt-get install -y python-software-properties
# Install PHP 5.4
add-apt-repository ppa:ondrej/php5
# Update
apt-get update

# PHP stuff
# ---------
# Command-Line Interpreter
apt-get install -y php5-cli
# MySQL database connections directly from PHP
apt-get install -y php5-mysql
# cURL is a library for getting files from FTP, GOPHER, HTTP server
apt-get install -y php5-curl
# Module for MCrypt functions in PHP
apt-get install -y php5-mcrypt

# cURL
# ----
apt-get install -y curl

# Mysql
# -----
# Ignore the post install questions
export DEBIAN_FRONTEND=noninteractive
# Install MySQL quietly
apt-get -q -y install mysql-server-5.5

# Git
# ---
apt-get install git-core

# Install Composer
# ----------------
curl -s https://getcomposer.org/installer | php
# Make Composer available globally
mv composer.phar /usr/local/bin/composer

# Laravel stuff
# -------------
# Set name of Laravel Site
lsite="ldev"
# Load Composer packages
cd /var/www
composer global require "laravel/installer=~1.1"
ln -s ~/.composer/vendor/bin/laravel $HOME/bin/laravel
laravel new $lsite

# Set up the database
echo "CREATE DATABASE IF NOT EXISTS $lsite" | mysql
echo "CREATE USER 'jostua'@'localhost' IDENTIFIED BY ''" | mysql
echo "GRANT ALL PRIVILEGES ON $lsite.* TO 'jostua'@'localhost' IDENTIFIED BY ''" | mysql
# Run artisan migrate to setup the database and schema, then seed it
php artisan migrate --env=development
php artisan db:seed --env=development

# Update Apache2
# --------------
# Remove /var/www default
rm -rf /var/www
# Symlink /vagrant to /var/www
ln -fs /vagrant /var/www
# Add ServerName to httpd.conf
echo "ServerName localhost" > /etc/apache2/httpd.conf
# Setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
  DocumentRoot "/vagrant/$lsite/public"
  ServerName localhost
  <Directory "/vagrant/$lsite/public">
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-enabled/000-default
# Enable mod_rewrite
a2enmod rewrite
# Restart apache
service apache2 restart

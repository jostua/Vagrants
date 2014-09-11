#!/usr/bin/env bash

####
#
# Update apt
# Install Apache / MySQL / PHP
# Get neo4j
# Configure environment
#
####

####
#
# Apt
#
####

# Import Neo4j signing key
wget -O - http://debian.neo4j.org/neotechnology.gpg.key | apt-key add - 
# Create an Apt sources.list file for Neo4j
echo 'deb http://debian.neo4j.org/repo stable/' > /etc/apt/sources.list.d/neo4j.list
apt-get update
apt-get dist-upgrade

####
#
# LAMP components
#
####

apt-get -y install apache2 libapache2-mod-php5
apt-get -y install mysql-server mysql-client
apt-get -y install php5 php5-cli php5-mysql php5-cgi

####
#
# Neo4j
#
####

# Install Neo4j, community edition
apt-get -y install neo4j

####
#
# Environment
#
####

# set the open file handles limit. Neo needs a lot.
ulimit -n 999999

# start neo4j server, available at http://localhost:7474 of the target machine
neo4j start


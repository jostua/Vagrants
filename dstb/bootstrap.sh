#!/bin/bash

###
#
# Install Rstudio
#
###

echo "deb http://cran.rstudio.com/bin/linux/ubuntu precise/" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9

sudo -E apt-get --yes --force-yes update

#### Ensure that R is up-to-date
sudo -E apt-get --yes --force-yes install r-base-dev

#### install rstudio-server
sudo -E apt-get --yes --force-yes install gdebi-core
sudo -E apt-get --yes --force-yes install libapparmor1
wget http://download2.rstudio.org/rstudio-server-0.98.1056-amd64.deb
sudo gdebi --n rstudio-server-0.98.1056-amd64.deb
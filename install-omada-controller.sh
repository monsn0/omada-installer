#!/bin/bash
#title           :install-omada-controller.sh
#description     :Omada Controller Installer for Ubuntu 18.04
#author          :monsn0
#date            :2021-07-29

# Update this variable with the URL to latest available version
OmadaPackageDl=https://static.tp-link.com/software/2021/202107/20210701/Omada_SDN_Controller_v4.4.3_linux_x64.deb

# Import the MongoDB 3.6 public key and add repo
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 58712A2291FA4AD5
echo "deb http://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list
apt update

# Install the 3 dependencies not included in Ubuntu 18.04
apt install openjdk-8-jre-headless -y
apt install mongodb-org -y
apt install jsvc -y

# Download Omada Controller package and install
wget $OmadaPackageDl -P /tmp/
dpkg -i /tmp/$(basename $OmadaPackageDl)

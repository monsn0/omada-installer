#!/bin/bash
#title           :install-omada-controller.sh
#description     :Omada Controller Installer for Ubuntu
#supports        :Ubuntu 14.04, Ubuntu 16.04, Ubuntu 18.04
#author          :monsn0
#date            :2021-07-29

# URL of latest available version of the Omada Controller package
OmadaPackageUrl=https://static.tp-link.com/software/2021/202107/20210701/Omada_SDN_Controller_v4.4.3_linux_x64.deb

OS=$(hostnamectl | grep "Operating System")
echo $OS

if [[ $OS = *"Ubuntu 14.04"* ]]; then
    OsVer=trusty
elif [[ $OS = *"Ubuntu 16.04"* ]]; then
    OsVer=xenial
elif [[ $OS = *"Ubuntu 18.04"* ]]; then
    OsVer=bionic
else
    echo -e "\e[1;31mERROR: Script only supports Ubuntu 14.04, 16.04, or 18.04! \e[0m"
    exit
fi

# Import the MongoDB 3.6 public key and add repo
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 58712A2291FA4AD5
echo "deb http://repo.mongodb.org/apt/ubuntu $OsVer/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list

# Install/update dependencies
apt update
apt install openjdk-8-jre-headless -y
apt install mongodb-org -y
apt install jsvc -y
apt install curl -y

# Download Omada Controller package and install
wget $OmadaPackageUrl -P /tmp/
dpkg -i /tmp/$(basename $OmadaPackageUrl)

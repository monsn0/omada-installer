#!/bin/bash
#title           :install-omada-controller.sh
#description     :Omada Controller Installer for Ubuntu
#supported       :Ubuntu 16.04, Ubuntu 18.04, Ubuntu 20.04, Ubuntu 22.04
#author          :monsn0
#date            :2021-07-29
#updated         :2023-11-18

OS=$(hostnamectl status | grep "Operating System")
echo $OS

if [[ $OS = *"Ubuntu 16.04"* ]]; then
    OsVer=xenial
elif [[ $OS = *"Ubuntu 18.04"* ]]; then
    OsVer=bionic
elif [[ $OS = *"Ubuntu 20.04"* ]]; then
    OsVer=focal
elif [[ $OS = *"Ubuntu 22.04"* ]]; then
    # $OsVer is also set to 'focal' as MongoDB 4.4 is not offically supported on 22.04
    OsVer=focal
    # Install libssl 1.1 as required by MongoDB 4.4 on Ubuntu 22.04
    wget -qP /tmp/ http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
    dpkg -i /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb &> /dev/null
else
    echo -e "\e[1;31mERROR: Script only supports Ubuntu 16.04, 18.04, 20.04 or 22.04! \e[0m"
    exit
fi

# Import the MongoDB 4.4 public key and add repo
apt-get -qq update
apt-get -qq install gnupg
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 656408E390CFB1F5
echo "deb http://repo.mongodb.org/apt/ubuntu $OsVer/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list

# Install/update dependencies
apt-get -qq update
apt-get -y install openjdk-8-jre-headless mongodb-org jsvc curl

# Download Omada Controller package and install
OmadaPackageUrl=$(curl -s https://www.tp-link.com/us/support/download/omada-software-controller/ | grep -oP '<a[^>]*href="\K[^"]*Linux_x64.deb[^"]*' | head -n 1)
wget $OmadaPackageUrl -P /tmp/
dpkg -i /tmp/$(basename $OmadaPackageUrl)

hostIP=$(hostname -I | cut -f1 -d' ')
echo -e "\n\nOmada SDN Controller is now installed! \nVisit https://${hostIP}:8043 from another machine on your network to manage. :)"

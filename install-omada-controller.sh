#!/bin/bash
#title           :install-omada-controller.sh
#description     :Omada Controller Installer for Ubuntu
#supported       :Ubuntu 16.04, Ubuntu 18.04, Ubuntu 20.04, Ubuntu 22.04
#author          :monsn0
#date            :2021-07-29
#updated         :2023-11-18

echo -e "TP-Link Omada SDN Controller Installer \nhttps://github.com/monsn0/omada-installer \n"

echo "[+] Checking for supported OS"
OS=$(hostnamectl status | grep "Operating System")
echo "[+] $OS"

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
    echo "[+] Installing libssl 1.1 package for Ubuntu 22.04"
    wget -qP /tmp/ http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
    dpkg -i /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb 1> /dev/null
else
    echo -e "\e[1;31mERROR: Script only supports Ubuntu 16.04, 18.04, 20.04 or 22.04! \e[0m"
    exit
fi

# Import the MongoDB 4.4 public key and add repo
echo "[+] Importing the MongoDB 4.4 PGP key and creating repository"
apt-get -qq update
apt-get -qq install gnupg
curl -fsSL https://pgp.mongodb.com/server-4.4.asc | gpg -o /usr/share/keyrings/mongodb-server-4.4.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-4.4.gpg ] https://repo.mongodb.org/apt/ubuntu $OsVer/mongodb-org/4.4 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.4.list

# Install/update dependencies
echo "[+] Installing/updating OpenJDK 8, JSVC, MongoDB 4.4 and cURL"
apt-get -qq update
apt-get -qq install openjdk-8-jre-headless mongodb-org jsvc curl

# Download Omada Controller package and install
echo "[+] Downloading latest Omada SDN Controller package"
OmadaPackageUrl=$(curl -s https://www.tp-link.com/us/support/download/omada-software-controller/ | grep -oP '<a[^>]*href="\K[^"]*Linux_x64.deb[^"]*' | head -n 1)
wget -qP /tmp/ $OmadaPackageUrl
echo "[+] Installing Omada SDN Controller"
dpkg -i /tmp/$(basename $OmadaPackageUrl) 1> /dev/null

hostIP=$(hostname -I | cut -f1 -d' ')
echo -e "\n[+] Omada SDN Controller is now installed! :) \n[+] Visit https://${hostIP}:8043 to complete the inital setup wizard."

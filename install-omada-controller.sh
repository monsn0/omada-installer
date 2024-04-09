#!/bin/bash
#title           :install-omada-controller.sh
#description     :Installer for TP-Link Omada Software Controller
#supported       :Ubuntu 16.04, Ubuntu 18.04, Ubuntu 20.04, Ubuntu 22.04
#author          :monsn0
#date            :2021-07-29
#updated         :2024-04-07

function os_ubuntu_base
{
    if [[ ! "$1" == "xenial" ]] && [[ ! "$1" == "bionic" ]] && [[ ! "$1" == "focal" ]] && [[ ! "$1" == "jammy" ]]; then
        echo -e "\e[1;31m[!] This script only supports Ubuntu 16.04, 18.04, 20.04 or 22.04! \e[0m"
        exit 1
    fi

    if [[ "$1" == "jammy" ]]; then
        # $VERSION_CODENAME is also set to 'focal' as MongoDB 4.4 is not offically supported on 22.04
        # Install libssl 1.1 as required by MongoDB 4.4 on Ubuntu 22.04
        VERSION_CODENAME=focal
        echo "[+] Installing libssl 1.1 package for Ubuntu 22.04"
        wget -qP /tmp/ http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
        dpkg -i /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb &> /dev/null       
    fi
}

function os_debuntu
{
    echo "[+] Installing script prerequisites"
    apt-get -qq update
    apt-get -qq install gnupg curl &> /dev/null

    echo "[+] Importing the MongoDB 4.4 PGP key and creating APT repository"
    curl -fsSL https://pgp.mongodb.com/server-4.4.asc | gpg -o /usr/share/keyrings/mongodb-server-4.4.gpg --dearmor
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-4.4.gpg ] https://repo.mongodb.org/apt/$ID $VERSION_CODENAME/mongodb-org/4.4 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.4.list

    # Package dependencies
    echo "[+] Installing MongoDB 4.4"
    apt-get -qq update
    apt-get -qq install mongodb-org &> /dev/null
    echo "[+] Installing OpenJDK 8 JRE (headless)"
    apt-get -qq install openjdk-8-jre-headless &> /dev/null
    echo "[+] Installing JSVC"
    apt-get -qq install jsvc &> /dev/null

    echo "[+] Downloading the latest Omada Software Controller package"
    OmadaPackageUrl=$(curl -fsSL https://www.tp-link.com/us/support/download/omada-software-controller/ | grep -oPi '<a[^>]*href="\K[^"]*Linux_x64.deb[^"]*' | head -n 1)
    wget -qP /tmp/ $OmadaPackageUrl
    echo "[+] Installing Omada Software Controller $(basename $OmadaPackageUrl | grep -oP 'v\d+(\.\d+)+')"
    dpkg -i /tmp/$(basename $OmadaPackageUrl) &> /dev/null
}


echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "TP-Link Omada Software Controller - Installer"
echo "https://github.com/monsn0/omada-installer"
echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

echo "[+] Verifying running as root"
if [ `id -u` -ne 0 ]; then
    echo -e "\e[1;31m[!] Script requires to be ran as root. Please rerun using sudo. \e[0m"
    exit
fi

echo "[+] Verifying supported OS"
if [[ -r "/etc/os-release" ]]; then
    source /etc/os-release
    echo "[~] Detected OS: $PRETTY_NAME"

    if [[ "$ID" == "ubuntu" ]]; then
        os_ubuntu_base "$VERSION_CODENAME"
        os_debuntu
    else
        echo -e "\e[1;31m[!] You appear to be running a currently unsupported OS version. Please see the readme. \e[0m"
        exit 1
    fi
else
    echo -e "\e[1;31m[!] You appear to be running a currently unsupported OS version. Please see the readme. \e[0m"
    exit 1
fi

hostIP=$(hostname -I | cut -f1 -d' ')
echo -e "\e[0;32m[~] Omada Software Controller has been successfully installed! :)\e[0m"
echo -e "\e[0;32m[~] Please visit https://${hostIP}:8043 to complete the inital setup wizard.\e[0m\n"



grep -oP '\d+(\.\d+)+'
grep -oP '(?<=\/v)\d+(\.\d+)+(?=_)'
#!/bin/bash
#title           :install-omada-controller.sh
#description     :Installer for TP-Link Omada Software Controller
#supported       :Ubuntu 20.04, Ubuntu 22.04, Ubuntu 24.04; Debian Linux 12; AlmaLinux 10; Rocky Linux 10
#author          :monsn0
#date            :2021-07-29
#updated         :2025-07-17

echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "TP-Link Omada Software Controller - Installer"
echo "https://github.com/monsn0/omada-installer"
echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

if [ -e "/usr/bin/tpeap" ]; then
  echo -e "\e[1;31m[!] It appears the controller is already installed. Script only supports new installs. \e[0m\n"
  exit
fi

echo "[+] Verifying running as root"
if [ `id -u` -ne 0 ]; then
  echo -e "\e[1;31m[!] Script requires to be ran as root. Please rerun using sudo. \e[0m"
  exit
fi

echo "[+] Verifying supported CPU"
if ! lscpu | grep -iq avx; then
    echo -e "\e[1;31m[!] Your CPU does not support AVX. MongoDB 5.0+ requires an AVX supported CPU. \e[0m"
    exit
fi

echo "[+] Verifying supported OS"
OS=$(hostnamectl status | grep "Operating System" | sed 's/^[ \t]*//')
echo "[~] $OS"

if [[ $OS = *"Ubuntu 20.04"* ]]; then
    OsVer=focal
    OsType=ubuntu
elif [[ $OS = *"Ubuntu 22.04"* ]]; then
    OsVer=jammy
    OsType=ubuntu
elif [[ $OS = *"Ubuntu 24.04"* ]]; then
    OsVer=noble
    OsType=ubuntu
elif [[ $OS = *"Debian GNU/Linux 12"* ]]; then
    OsVer=bookworm
    OsType=debian
elif [[ $OS = *"Rocky Linux 10"* ]]; then
    OsVer=9
    OsType=rocky
elif [[ $OS = *"AlmaLinux 10"* ]]; then
    OsVer=9
    OsType=alma
else
    echo -e "\e[1;31m[!] \n Script currently only supports the following: \n APT: Ubuntu 20.04, 22.04, 24.04; Debian 12 Bookworm \n YUM: AlmaLinux 9, 10 or Rocky Linux 9, 10\n[!] \e[0m"
    exit
fi




install_ubuntu() {
echo "[+] Installing script prerequisites"
apt-get -qq update
apt-get -qq install gnupg curl &> /dev/null

echo "[+] Importing the MongoDB 8.0 PGP key and creating the APT repository"
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu $OsVer/mongodb-org/8.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-8.0.list
apt-get -qq update

echo "[+] Downloading the latest Omada Software Controller package"
OmadaPackageUrl=$(curl -fsSL https://support.omadanetworks.com/us/product/omada-software-controller/?resourceType=download | grep -oPi '<a[^>]*href="\K[^"]*linux_x64_[0-9]*\.deb[^"]*' | head -n 1)
OmadaPackageBasename=$(basename $OmadaPackageUrl)
curl -sLo /tmp/$OmadaPackageBasename $OmadaPackageUrl

# Package dependencies
echo "[+] Installing MongoDB 8.0"
apt-get -qq install mongodb-org &> /dev/null
echo "[+] Installing OpenJDK 21 JRE (headless)"
apt-get -qq install openjdk-21-jre-headless &> /dev/null
echo "[+] Installing JSVC"
apt-get -qq install jsvc &> /dev/null

echo "[+] Installing Omada Software Controller $(echo $OmadaPackageBasename | tr "_" "\n" | sed -n '2p')"
dpkg -i /tmp/$OmadaPackageBasename &> /dev/null
}


install_debian() {
echo "[+] Installing script prerequisites"
apt-get -qq update
apt-get -qq install gnupg curl &> /dev/null

echo "[+] Importing the MongoDB 8.0 PGP key and creating the APT repository"
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/debian $OsVer/mongodb-org/8.0 main" > /etc/apt/sources.list.d/mongodb-org-8.0.list
apt-get -qq update

echo "[+] Downloading the latest Omada Software Controller package"
OmadaPackageUrl=$(curl -fsSL https://support.omadanetworks.com/us/product/omada-software-controller/?resourceType=download | grep -oPi '<a[^>]*href="\K[^"]*linux_x64_[0-9]*\.deb[^"]*' | head -n 1)
OmadaPackageBasename=$(basename $OmadaPackageUrl)
curl -sLo /tmp/$OmadaPackageBasename $OmadaPackageUrl

# Package dependencies
echo "[+] Installing MongoDB 8.0"
apt-get -qq install mongodb-org &> /dev/null
echo "[+] Installing OpenJDK 21 JRE (headless)"
apt-get -qq install openjdk-21-jre-headless &> /dev/null
echo "[+] Installing JSVC"
apt-get -qq install jsvc &> /dev/null

echo "[+] Installing Omada Software Controller $(echo $OmadaPackageBasename | tr "_" "\n" | sed -n '4p')"
dpkg -i /tmp/$OmadaPackageBasename &> /dev/null
}


install_rockylinux() {
echo "[+] Installing script prerequisites"
#sudo dnf makecache --refresh
sudo dnf check-update
sudo dnf -y install dnf-utils curl wget glibc initscripts &> /dev/null

echo "[+] Importing the MongoDB 8.0 PGP key and creating the DNF repository"
sudo tee /etc/yum.repos.d/mongodb-org-8.0.repo<<EOF
[mongodb-org-8.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$OsVer/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-8.0.asc
EOF

echo "[+] Downloading the latest Omada Software Controller package"
OmadaPackageUrl=$(curl -fsSL https://support.omadanetworks.com/us/product/omada-software-controller/?resourceType=download | grep -oPi '<a[^>]*href="\K[^"]*linux_x64_[0-9]*\.tar.gz[^"]*' | head -n 1)
OmadaPackageBasename=$(basename $OmadaPackageUrl)
curl -sLo /tmp/$OmadaPackageBasename $OmadaPackageUrl

# Package dependencies
echo "[+] Installing MongoDB 8.0"
sudo dnf -y install mongodb-org &> /dev/null
echo "[+] Installing OpenJDK 21 JRE (headless)"
sudo dnf -y install java-21-openjdk-headless &> /dev/null
echo "[+] Installing JSVC"
cd /tmp/
sudo wget https://download.opensuse.org/distribution/leap/15.6/repo/oss/x86_64/apache-commons-daemon-jsvc-1.3.4-150200.11.14.1.x86_64.rpm &> /dev/null
sudo dnf -y install ./apache-commons-daemon-jsvc-1.3.4-150200.11.14.1.x86_64.rpm &> /dev/null

#Open Firewall Ports
echo "[+] Opening Firewall Ports"
firewall-cmd --zone=public --add-port=8088/tcp --permanent &> /dev/null # http connection
firewall-cmd --zone=public --add-port=8043/tcp --permanent &> /dev/null # https connection
firewall-cmd --zone=public --add-port=29810/udp --permanent &> /dev/null # EAP Discovery
firewall-cmd --zone=public --add-port=29811/tcp --permanent &> /dev/null # EAP Management
firewall-cmd --zone=public --add-port=29812/tcp --permanent &> /dev/null # EAP Adoption
firewall-cmd --zone=public --add-port=29813/tcp --permanent &> /dev/null # EAP Upgrades and initialization check
firewall-cmd --reload

echo "[+] Installing Omada Software Controller $(echo $OmadaPackageBasename | tr "_" "\n" | sed -n '4p')"
cd /tmp/
sudo mkdir /tmp/omada-installer &> /dev/null
sudo tar -zxvf /tmp/Omada_SDN_Controller_v5.15.24.17_linux_x64_20250613204459.tar.gz --strip-components=1 -C /tmp/omada-installer/ &> /dev/null
cd /tmp/omada-installer/
sudo ./install.sh
}


install_almalinux() {
echo "[+] Installing script prerequisites"
#sudo dnf makecache --refresh
sudo dnf check-update
sudo dnf -y install dnf-utils curl wget glibc initscripts &> /dev/null

echo "[+] Importing the MongoDB 8.0 PGP key and creating the DNF repository"
sudo tee /etc/yum.repos.d/mongodb-org-8.0.repo<<EOF
[mongodb-org-8.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$OsVer/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-8.0.asc
EOF

echo "[+] Downloading the latest Omada Software Controller package"
OmadaPackageUrl=$(curl -fsSL https://support.omadanetworks.com/us/product/omada-software-controller/?resourceType=download | grep -oPi '<a[^>]*href="\K[^"]*linux_x64_[0-9]*\.tar.gz[^"]*' | head -n 1)
OmadaPackageBasename=$(basename $OmadaPackageUrl)
curl -sLo /tmp/$OmadaPackageBasename $OmadaPackageUrl

# Package dependencies
echo "[+] Installing MongoDB 8.0"
sudo dnf -y install mongodb-org &> /dev/null
echo "[+] Installing OpenJDK 21 JRE (headless)"
sudo dnf -y install java-21-openjdk-headless &> /dev/null
echo "[+] Installing JSVC"
cd /tmp/
sudo wget https://download.opensuse.org/distribution/leap/15.6/repo/oss/x86_64/apache-commons-daemon-jsvc-1.3.4-150200.11.14.1.x86_64.rpm &> /dev/null
sudo dnf -y install ./apache-commons-daemon-jsvc-1.3.4-150200.11.14.1.x86_64.rpm &> /dev/null

#Open Firewall Ports
echo "[+] Opening Firewall Ports"
firewall-cmd --zone=public --add-port=8088/tcp --permanent &> /dev/null # http connection
firewall-cmd --zone=public --add-port=8043/tcp --permanent &> /dev/null # https connection
firewall-cmd --zone=public --add-port=29810/udp --permanent &> /dev/null # EAP Discovery
firewall-cmd --zone=public --add-port=29811/tcp --permanent &> /dev/null # EAP Management
firewall-cmd --zone=public --add-port=29812/tcp --permanent &> /dev/null # EAP Adoption
firewall-cmd --zone=public --add-port=29813/tcp --permanent &> /dev/null # EAP Upgrades and initialization check
firewall-cmd --reload

echo "[+] Installing Omada Software Controller $(echo $OmadaPackageBasename | tr "_" "\n" | sed -n '4p')"
cd /tmp/
sudo mkdir /tmp/omada-installer &> /dev/null
sudo tar -zxvf /tmp/Omada_SDN_Controller_v5.15.24.17_linux_x64_20250613204459.tar.gz --strip-components=1 -C /tmp/omada-installer/ &> /dev/null
cd /tmp/omada-installer/
sudo ./install.sh
}


if [ "$OsType" = "ubuntu" ]; then
    install_ubuntu
elif [ "$OsType" = "debian" ]; then
    install_debian
elif [ "$OsType" = "rocky" ]; then
    install_rockylinux
elif [ "$OsType" = "alma" ]; then
    install_almalinux
else
	exit
fi


hostIP=$(hostname -I | cut -f1 -d' ')
echo -e "\e[0;32m[~] Omada Software Controller has been successfully installed! :)\e[0m"
echo -e "\e[0;32m[~] Please visit https://${hostIP}:8043 to complete the inital setup wizard.\e[0m\n"

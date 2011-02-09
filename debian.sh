#!/bin/sh

echo "Downloading and updating Debian packages"
apt-get install lsb-release
codename=`lsb_release -a|grep Codename|cut -f2`
if ! grep "^deb.*debian\.org.*non-free" /etc/apt/sources.list
then
  echo "deb http://ftp.debian.org/debian/ $codename non-free" | tee -a /etc/apt/sources.list
fi
apt-get update -y
apt-get upgrade -y
apt-get install binutils gcc g++ gfortran sun-java6-jdk -y
apt-get install wget hostname pwgen git-core raptor-utils r-base -y # xvfb 
. ./config
echo mysql-server-5.1 mysql-server/root_password password $mysql_root | debconf-set-selections
echo mysql-server-5.1 mysql-server/root_password_again password $mysql_root | debconf-set-selections
apt-get install mysql-server -y
apt-get install libssl-dev zlib1g-dev libreadline-dev libmysqlclient-dev libmysqlclient-dev libcurl4-openssl-dev libxml2-dev libxslt1-dev libgsl0.dev -y
sed -i '/^JAVA_HOME=/d' /etc/profile
echo 'export JAVA_HOME=/usr/lib/jvm/java-6-sun' | tee -a /etc/profile

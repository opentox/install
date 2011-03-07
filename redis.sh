#!/bin/sh

echo "Installing Redis database"
. /etc/profile
. ./config
dir=`pwd`
cd /tmp
wget -O - "http://redis.googlecode.com/files/redis-2.2.2.tar.gz" | tar zxv
cd redis-2.2.2
make install
echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
cd $dir

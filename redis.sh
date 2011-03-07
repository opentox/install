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
mkdir -p /opt/redis
echo "daemonize yes" > /opt/redis/redis.conf
echo "dir `pwd`" >> /opt/redis/redis.conf
edis-server /opt/redis/redis.conf
cd $dir

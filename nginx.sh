#!/bin/sh

. /etc/profile
passenger-install-nginx-module --auto-download --auto --prefix=/opt/nginx

cd /opt/ruby-enterprise-1.8.7-2010.03/lib/ruby/gems/1.8/gems/
passenger=`ls -d passenger*`;
cd -
servername=`hostname`.`dnsdomainname`
echo $passenger
sed -e "s/PASSENGER/$passenger/;s/SERVERNAME/$servername/" nginx.conf > /opt/nginx/conf/nginx.conf

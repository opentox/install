#!/bin/sh

echo "Installing Ruby Enterprise"
cd /tmp
wget -O - "http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise-1.8.7-2011.03.tar.gz" | tar zxv
sh /tmp/ruby-enterprise-1.8.7-2010.03/installer  --dont-install-useful-gems --no-dev-docs --auto=/opt/ruby-enterprise-1.8.7-2010.03
sed -i '/^PATH=.*ruby-enterprise/d' /etc/profile
echo 'PATH=$PATH:/opt/ruby-enterprise-1.8.7-2010.03/bin' | tee -a /etc/profile
. /etc/profile
gem sources -a http://gemcutter.org 
gem sources -r http://rubygems.org/
echo "gem: --no-ri --no-rdoc" | tee -a ~/.gemrc
gem install passenger
cd -

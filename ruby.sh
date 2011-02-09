#!/bin/sh

echo "Installing Ruby Enterprise"
cd /tmp
wget -O - "http://rubyforge.org/frs/download.php/71096/ruby-enterprise-1.8.7-2010.02.tar.gz" | tar zxv
ruby-enterprise-1.8.7-2010.02/installer  --dont-install-useful-gems --no-dev-docs --auto=/opt/ruby-enterprise-1.8.7-2010.02
sed -i '/^PATH=.*ruby-enterprise/d' /etc/profile
echo 'PATH=$PATH:/opt/ruby-enterprise-1.8.7-2010.02/bin' | tee -a /etc/profile
. /etc/profile
gem sources -a http://gemcutter.org 
gem sources -r http://rubygems.org/
echo "gem: --no-ri --no-rdoc" | tee -a ~/.gemrc
gem install passenger
cd -

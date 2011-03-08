#!/bin/sh

echo "Installing opentox-ruby gem"
. /etc/profile
. ./config
gem install opentox-ruby
gem install builder # not included by spreadsheet gem

dir=`pwd`

# create config file
servername=`hostname`.`dnsdomainname`
escapedservername=`echo $servername|sed 's/\/\\\//'`
if [ $branch = "development" ]
then
    logger=":logger: backtrace"
else
    logger=""
fi

if [ $install = "server" ]
then
    aa="https:\/\/opensso.in-silico.ch"
else
    aa=nil
fi

mkdir -p $HOME/.opentox/config
mkdir -p $HOME/.opentox/log
#sed -e "s/SERVERNAME/$servername/;s/LOGGER/$logger/;s/AA/$aa/" production.yaml > $HOME/.opentox/config/production.yaml
sed -e "s/PASSWORD/$password/;s/SERVERNAME/$servername/;s/ESCAPEDSERVERNAME/$escapedservername/;s/LOGGER/$logger/;s/AA/$aa/" production.yaml > $HOME/.opentox/config/production.yaml
sed -e "s/PASSWORD/$password/;s/SERVERNAME/$servername/;s/ESCAPEDSERVERNAME/$escapedservername/;s/LOGGER/$logger/;s/AA/$aa/" aa-$install.yaml >> $HOME/.opentox/config/production.yaml

# checkout development version and link lib to opentox-ruby gem
if [ $branch = "development" ]
then
    mkdir -p /var/www/opentox
    cd /var/www/opentox
    git clone http://github.com/helma/opentox-ruby.git 
    cd opentox-ruby
    git checkout -t origin/$branch
    rake install
    gem_lib=`gem which opentox-ruby`
    gem_lib=`echo $gem_lib | sed 's/\/opentox-ruby.rb//'`
    mv $gem_lib $gem_lib~
    ln -s /var/www/opentox/opentox-ruby/lib $gem_lib
fi
cd $dir

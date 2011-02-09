#!/bin/sh

echo "Installing opentox-ruby gem"
. /etc/profile
. ./config
gem install opentox-ruby

dir=`pwd`

# create config file
password=`pwgen 8 1`
servername=`hostname`.`dnsdomainname`
if [ $branch = "development" ]
then
    logger=":logger: backtrace"
else
    logger=""
fi

if [ $type = "server" ]
then
    aa="https:\/\/opensso.in-silico.ch"
else
    aa=nil
fi

mkdir -p $HOME/.opentox/config
mkdir -p $HOME/.opentox/log
sed -e "s/PASSWORD/$password/;s/SERVERNAME/$servername/;s/LOGGER/$logger/;s/AA/$aa/" production.yaml > $HOME/.opentox/config/production.yaml

# checkout development version and link lib to opentox-ruby gem
if [ $branch = "development" ]
then
    mkdir -p /var/www/opentox
    cd /var/www/opentox
    git clone http://github.com/mguetlein/opentox-ruby.git 
    cd opentox-ruby
    git checkout -t origin/$branch
    gem_lib=`gem which opentox-ruby`
    gem_lib=`echo $gem_lib | sed 's/\/opentox-ruby.rb//'`
    mv $gem_lib $gem_lib~
    ln -s /var/www/opentox/opentox-ruby/lib $gem_lib
fi
cd $dir

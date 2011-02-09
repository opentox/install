#!/bin/sh

echo "Installing OpenBabel libraries"
. /etc/profile
dir=`pwd`
cd /tmp
wget -O - "http://downloads.sourceforge.net/project/openbabel/openbabel/2.2.3/openbabel-2.2.3.tar.gz?use_mirror=kent" | tar zxv
cd openbabel-2.2.3/
./configure
make install
cd scripts/ruby/
ruby extconf.rb --with-openbabel-include=/usr/local/include/openbabel-2.0
make install
ldconfig
cd $dir

#!/bin/sh

echo "Installing fminer"
dir=`pwd`
cd /var/www/opentox/algorithm
git submodule init
git submodule update

cd libfminer/libbrc
git checkout master
git pull
./configure
make ruby

cd ../liblast
git checkout master
git pull
./configure
make ruby

cd ../../last-utils
git checkout master
git pull

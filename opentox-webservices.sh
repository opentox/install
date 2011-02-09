#!/bin/sh

echo "Installing OpenTox webservices"
. ./config
# Create opentox system user
id opentox
if [ $? -ne 0 ] 
then
   adduser --system opentox
fi

dir=`pwd`
mkdir -p /var/www/opentox
cd /var/www/opentox
for s in compound dataset algorithm model toxcreate task; do
    git clone git://github.com/helma/opentox-$s.git $s
    cd $s
    git checkout -t origin/$branch
    mkdir -p public
    ln -s /var/www/opentox/$s/public /var/www/$s
    cd -
done
git clone http://github.com/mguetlein/opentox-validation.git validation
cd validation
git checkout -t origin/$branch
cd /var/www/opentox/algorithm
rake fminer:install
chown -R opentox /var/www/opentox
cp -r $HOME/.opentox /home/opentox/
chown -R opentox /home/opentox/.opentox
cd $dir

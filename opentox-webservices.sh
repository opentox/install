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
    git clone git://github.com/opentox/$s.git $s
    cd $s
    git checkout -t origin/$branch
    mkdir -p public
    ln -s /var/www/opentox/$s/public /var/www/$s
    cd -
done

# validation service
#git clone http://github.com/mguetlein/opentox-validation.git validation
#cd /var/www/opentox/validation
#git checkout -t origin/test
#gem install ruby-plot
#mkdir -p public
#ln -s /var/www/opentox/validation/public /var/www/validation

# fminer etc
cd /var/www/opentox/algorithm
updatedb
rake fminer:install
chown -R opentox /var/www/opentox
cp -r $HOME/.opentox /home/opentox/
chown -R opentox /home/opentox/.opentox
cd $dir

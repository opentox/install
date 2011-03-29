#!/bin/bash
#
# Installs Opentox Webservices.
# Author: Christoph Helma, Andreas Maunz.
#

if [ "$(id -u)" = "0" ]; then
  echo "This script must be run as non-root." 1>&2
  exit 1
fi

# Utils
WGET="`which wget`"
if [ ! -e "$WGET" ]; then
  echo "'wget' missing. Install 'wget' first. Aborting..."
  exit 1
fi

source ./config.sh

echo "This installs Opentox webservices."
echo "Press <Return> to continue, or <Ctrl+C> to abort."
read

DIR=`pwd`

mkdir -p "$WWW_DEST/opentox"
cd "$WWW_DEST/opentox"
for s in compound dataset algorithm model toxcreate task; do
    git clone "git://github.com/opentox/$s.git" "$s"
    cd "$s"
    git checkout -t origin/development # AM: use development
    mkdir public
    ln -s "$WWW_DEST/opentox/$s/public" "$WWW_DEST/$s"
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
cd $WWW_DEST/opentox/algorithm
echo "Need root password:"
sudo updatedb
rake fminer:install
cp -r "$HOME/.opentox" "$HOME"

cd "$DIR"
echo
echo "Opentox installation finished."

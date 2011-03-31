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
source ./utils.sh
LOG="/tmp/`basename $0`-log.txt"

echo "This installs Opentox webservices."
echo "Log file is '$LOG'."
echo "Press <Return> to continue, or <Ctrl+C> to abort."
read

DIR=`pwd`

echo "Checking out webservices..."
mkdir -p "$WWW_DEST/opentox" >>$LOG 2>&1
cd "$WWW_DEST/opentox" >>$LOG 2>&1
for s in compound dataset algorithm model toxcreate task; do
    git clone "git://github.com/opentox/$s.git" "$s" >>$LOG 2>&1

    cd "$s" >>$LOG 2>&1

    git checkout -t origin/development  >>$LOG 2>&1
# AM: use development
    mkdir public >>$LOG 2>&1

    if ln -s "$WWW_DEST/opentox/$s/public" "$WWW_DEST/$s" >>$LOG 2>&1; then
      printf "%25s%15s\n" "'Linking $s'" "FAIL"
      exit 1
    fi
    printf "%25s%15s\n" "'Linking $s'" "DONE"

    cd - >>$LOG 2>&1

done

# validation service
#git clone http://github.com/mguetlein/opentox-validation.git validation
#cd /var/www/opentox/validation
#git checkout -t origin/test
#gem install ruby-plot
#mkdir -p public
#ln -s /var/www/opentox/validation/public /var/www/validation

# fminer etc
echo "Compiling Fminer..."

if ! [ -f $HOME/.opentox/production.yaml ]; then
    printf "%25s%15s\n" "'Config present'" "N"
    exit 1
fi
printf "%25s%15s\n" "'Config present'" "Y"

cd $WWW_DEST/opentox/algorithm >>$LOG 2>&1
echo "Need root password:"
sudo updatedb >>$LOG 2>&1
if ! rake fminer:install >>$LOG 2>&1; then
    printf "%25s%15s\n" "'Make'" "FAIL"
    exit 1
fi
printf "%25s%15s\n" "'Make'" "FAIL"

cd "$DIR"
echo
echo "Opentox webservices installation finished."

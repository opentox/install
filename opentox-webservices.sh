#!/bin/bash
#
# Installs Opentox Webservices.
# Author: Christoph Helma, Andreas Maunz.
#

source ./config.sh
source ./utils.sh

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

RAKE="`which rake`"
if [ ! -e "$RAKE" ]; then
  echo "'rake' missing. Install 'rake' first. Aborting..."
  exit 1
fi

LOG="/tmp/`basename $0`-log.txt"

echo "Webservices ('$LOG'):"

DIR=`pwd`

mkdir -p "$WWW_DEST/opentox" >>$LOG 2>&1
cd "$WWW_DEST/opentox" >>$LOG 2>&1
for s in compound dataset algorithm model toxcreate task; do
    git clone "git://github.com/opentox/$s.git" "$s" >>$LOG 2>&1

    cd "$s" >>$LOG 2>&1

    git checkout -t origin/development  >>$LOG 2>&1 # AM: use development

    rm -rf public >>$LOG 2>&1
    mkdir public >>$LOG 2>&1

    mypath_from="$WWW_DEST/opentox/$s/public"
    mypath_to="$WWW_DEST/$s"
    cmd="ln -sf \"$mypath_from\" \"$mypath_to\"" && run_cmd "$cmd" "Linking $s"

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
cmd="test -f $HOME/.opentox/config/production.yaml" && run_cmd "$cmd" "Config present"
cd $WWW_DEST/opentox/algorithm >>$LOG 2>&1
sudo updatedb >>$LOG 2>&1
cmd="$RAKE fminer:install" && run_cmd "$cmd" "Make"

cd "$DIR"


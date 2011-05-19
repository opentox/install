#!/bin/sh
# Update script for OpenTox-ruby and webservices
# Authors: Andreas Maunz, David Vorgrimmler
# This script updates a productiv version of IST Opentox Services. All data will be saved and recovered.
# Make sure your web services are down befor running this script.
# You may modify some variables e.g. HOME, OTPREFIX, BACKUP_DIR.
# opentox/install is needed and has to be configured

HOME="/home/davor"
. $HOME/.opentox-ui.sh

OTPREFIX="$HOME/opentox"
BACKUP_DIR="$OTPREFIX/toxcreate3-backup"
mkdir $BACKUP_DIR >/dev/null 2>&1
mkdir -p $BACKUP_DIR/tmp/dataset/public >/dev/null 2>&1
mkdir -p $BACKUP_DIR/tmp/model/public >/dev/null 2>&1
mkdir -p $BACKUP_DIR/tmp/validation >/dev/null 2>&1
#mkdir -p $BACKUP_DIR/tmp/log >/dev/null 2>&1


echo "Creating backup of www..."
TAR_NAME=$BACKUP_DIR/"www_`date +%y%m%d`.tar.gz"

if [ -e $TAR_NAME ] || tar czvf $TAR_NAME "$OTPREFIX/opentox-ruby/www"; then
  echo
  echo "Will delete www in 10s! Press Ctrl+C to abort..."
  sleep 10
  sudo rm -rf "$OTPREFIX/opentox-ruby/www"
fi


NGINX="`which nginx`"
RAKE="`which rake`"

if ! [ -e "$RAKE" ]; then
  echo "Rake not found."
  exit 1
fi
if ! [ -e "$NGINX" ]; then
  echo "Nginx not found."
  exit 1
fi
if ! cd "$OTPREFIX/install"; then
  echo "$OTPREFIX/install dir not found"
fi


OTINSTALL="$OTPREFIX/install/opentox-webservices.sh"
if ! [ -e "$OTINSTALL" ]; then
  echo "$OTINSTALL not found."
  exit 1
fi
chmod +x $OTINSTALL
`$OTINSTALL`
echo "$OTINSTALL script end."


OTRUBYINSTALL="$OTPREFIX/install/opentox-ruby.sh"
if ! [ -e "$OTRUBYINSTALL" ]; then
  echo "$OTRUBYINSTALL not found."
  exit 1
fi
chmod +x $OTRUBYINSTALL
`$OTRUBYINSTALL`
echo "$OTRUBYINSTALL script end."


echo "Extracting backup of www..."
cd /
DEST_DATASET=`echo "$OTPREFIX/opentox-ruby/www/opentox/dataset/public/*yaml" | sed 's/.\(.*\)/\1/'`
DEST_MODEL=`echo "$OTPREFIX/opentox-ruby/www/opentox/model/public/*yaml" | sed 's/.\(.*\)/\1/'`
DEST_REPORTS=`echo "$OTPREFIX/opentox-ruby/www/opentox/validation/reports" | sed 's/.\(.*\)/\1/'`
tar xzvf $TAR_NAME --wildcards $DEST_DATASET
tar xzvf $TAR_NAME --wildcards $DEST_MODEL
tar xzvf $TAR_NAME $DEST_REPORTS
cd -
echo "End of script."

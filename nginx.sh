#!/bin/bash
#
# Installs Passenger.
# Author: Christoph Helma, Andreas Maunz.
#

source ./config.sh
source ./utils.sh

if [ "$(id -u)" = "0" ]; then
  echo "This script must be run as non-root." 1>&2
  exit 1
fi

# Utils
PIN="`which passenger-install-nginx-module`"
if [ ! -e "$PIN" ]; then
  echo "'passenger-install-nginx-module' missing. Install 'passenger-install-nginx-module' first. Aborting..."
  exit 1
fi

LOG="/tmp/`basename $0`-log.txt"

echo
echo "Nginx ('$LOG'):"

DIR="`pwd`"

NGINX_DONE=false
mkdir "$NGINX_DEST" >/dev/null 2>&1
if [ ! -d "$NGINX_DEST" ]; then
  echo "Install directory '$NGINX_DEST' is not available! Aborting..."
  exit 1
else
  if ! rmdir "$NGINX_DEST" >/dev/null 2>&1; then # if not empty this will fail
    echo "Install directory '$NGINX_DEST' not empty. Skipping nginx installation."
    NGINX_DONE=true
  fi
fi

if ! $NGINX_DONE; then
  cmd="$PIN --auto-download --auto --prefix=$NGINX_DEST" && run_cmd "$cmd" "Install"
  cd "$RUBY_DEST/lib/ruby/gems/1.8/gems/" >>$LOG 2>&1
  passenger=`ls -d passenger*`;
  cd - >>$LOG 2>&1
  servername=`hostname`
  sed -e "s/PASSENGER/$passenger/;s/SERVERNAME/$servername/;s/RUBY_DEST/$RUBY_DEST/" ./nginx.conf > $NGINX_DEST/nginx.conf 2>>$LOG 
fi

cd "$DIR"


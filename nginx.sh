#!/bin/sh
#
# Installs Passenger.
# Author: Christoph Helma, Andreas Maunz.
#

. "`pwd`/utils.sh"
DIR="`pwd`"

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

NGINX_DONE=false
mkdir "$NGINX_DEST" >/dev/null 2>&1
if [ ! -d "$NGINX_DEST" ]; then
  echo "Install directory '$NGINX_DEST' is not available! Aborting..."
  exit 1
else
  if ! rmdir "$NGINX_DEST" >/dev/null 2>&1; then # if not empty this will fail
    NGINX_DONE=true
  fi
fi

if ! $NGINX_DONE; then
  cmd="$PIN --auto-download --auto --prefix=$NGINX_DEST" && run_cmd "$cmd" "Install"
  cd "$RUBY_DEST/lib/ruby/gems/1.8/gems/" >>$LOG 2>&1
  passenger=`ls -d passenger*`
  cd - >>$LOG 2>&1
  servername=`hostname`
  ruby_dest=`echo $RUBY_DEST | sed 's/\//\\\//g'`
  nginx_dest=`echo $NGINX_DEST | sed 's/\//\\\//g'`
  cmd="sed -i -e \"s/PASSENGER/$passenger/;s/SERVERNAME/$servername/;s/RUBY_DEST/$ruby_dest/;s/NGINX_DEST/$nginx_dest/\" ./nginx.conf" && run_cmd "$cmd" "Config"
  cmd="cp ./nginx.conf \"$NGINX_DEST/conf\"" && run_cmd "$cmd" "Copy"
fi

cd "$DIR"


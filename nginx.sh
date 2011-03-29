#!/bin/bash
#
# Installs Passenger.
# Author: Christoph Helma, Andreas Maunz.
#

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

source ./config.sh
$PIN --auto-download --auto --prefix="$NGINX_DEST"

cd $RUBY_DEST/lib/ruby/gems/1.8/gems/
passenger=`ls -d passenger*`;
cd -
servername=`hostname`.`dnsdomainname`
sed -e "s/PASSENGER/$passenger/;s/SERVERNAME/$servername/" ./nginx.conf > $NGINX_DEST/nginx.conf

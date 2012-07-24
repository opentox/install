#!/bin/sh

# Installs required packages on Debian and compatible systems.
# Author: Andreas Maunz

# NOTE: Your installed packages are safe and will not be updated.
# Java configuration is included in '$OT_UI_CONF'.

. ./utils.sh
DIR=`pwd`

if [ "$(id -u)" = "0" ]; then
  echo "This script must not be run as root" 1>&2
  exit 1
fi

# Utils
check_utils "aptitude git apt-cache dpkg"

touch $OT_UI_CONF

# Pkgs
packs="binutils build-essential cmake curl gnuplot hostname libcurl4-openssl-dev libgsl0-dev libopenbabel4 libopenbabel-dev libraptor1-dev libreadline6-dev libreadline-dev libsqlite3-dev libssl-dev libyaml-dev libxml2-dev libxslt1-dev lsb-release openjdk-6-jdk psmisc pwgen raptor-utils r-base r-base-core r-base-dev sqlite3 udev wget xsltproc zlib1g-dev"

echo
echo "Base Packages:"

echo
echo "Updating index"
sudo $APTITUDE update -y >/dev/null 2>&1

pack_arr=$packs
if [ -n "$pack_arr" ]; then
  echo 
  echo "Checking availablity:"
  for p in $pack_arr; do
    if [ -n "`$APT_CACHE search $p`" ] ; then
       printf "%30s%50s\n" $p Y
    else
      printf "%30s%50s\n" $p N
      pack_fail="$pack_fail $p"
    fi
  done
fi

if [ -n "$pack_fail" ]; then
  echo 
  echo "WARNING: At least one missing package has no suitable installation candidate."
  echo "Press <Ctrl+C> to abort (5 sec)."
  sleep 5
fi

echo
if [ -n "$pack_arr" ]; then 
  cmd="sudo $APTITUDE -y install $pack_arr" && run_cmd "$cmd" "Installing packages"
fi


if [ ! -f $JAVA_CONF ]; then

  if [ ! -d "$OT_JAVA_HOME" ]; then
    echo "Directory '$OT_JAVA_HOME' does not exist! Aborting..."
    exit 1
  fi

  echo "if echo \"\$JAVA_HOME\" | grep -v \"$OT_JAVA_HOME\">/dev/null 2>&1; then export JAVA_HOME=\"$OT_JAVA_HOME\"; fi" >> "$JAVA_CONF"
  echo "if echo \"\$PATH\" | grep -v \"$OT_JAVA_HOME\">/dev/null 2>&1; then export PATH=\"$OT_JAVA_HOME:\$PATH\"; fi" >> "$JAVA_CONF"
  echo "if ! [ -d \"\$JAVA_HOME\" ]; then echo \"\$0: '\$OT_JAVA_HOME' is not a directory!\"; fi" >> "$JAVA_CONF"

  echo "Java configuration has been stored in '$JAVA_CONF'."
  if ! grep "$JAVA_CONF" $OT_UI_CONF >/dev/null 2>&1; then
    echo '. '$JAVA_CONF >> $OT_UI_CONF
  fi
fi

cd "$DIR"


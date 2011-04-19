#!/bin/sh
#
# Installs base packages for Ubuntu
# Author: Andreas Maunz
#
# Your installed packages are safe and will not be updated.
# A Java configuration is created and included in your '$OT_UI_CONF'.

. "`pwd`/utils.sh"
DIR="`pwd`"

if [ "$(id -u)" = "0" ]; then
  echo "This script must not be run as root" 1>&2
  exit 1
fi

# Utils
APTITUDE="`which aptitude`"
APT_CACHE="`which apt-cache`"
DPKG="`which dpkg`"

if [ ! -e "$APTITUDE" ]; then
  echo "Aptitude missing. Install aptitude first." 1>&2
  exit 1
fi

touch $OT_UI_CONF

# Pkgs
packs="binutils git-core hostname libcurl4-openssl-dev libgsl0-dev libreadline5-dev libreadline-dev libssl-dev libxml2-dev libxslt1-dev lsb-release pwgen raptor-utils r-base r-base-dev sun-java6-jdk wget zlib1g-dev"

echo
echo "Base Packages:"

pack_arr=""
for p in $packs; do
  if $DPKG -s "$p" >/dev/null 2>&1; then
     printf "%50s%30s\n" "'$p'" "Y"
  else
     printf "%50s%30s\n" "'$p'" "N"
    pack_arr="$pack_arr $p"
  fi
done

if [ -n "$pack_arr" ]; then
  echo 
  echo "Checking availablity:"
  sudo $APTITUDE update -y >/dev/null 2>&1
  sudo $APTITUDE upgrade -y >/dev/null 2>&1
fi

for p in $pack_arr; do
  if [ -n "`$APT_CACHE search $p`" ] ; then
     printf "%50s%30s\n" "'$p'" "Y"
  else
    printf "%50s%30s\n" "'$p'" "N"
    pack_fail="$pack_fail $p"
  fi
done

if [ -n "$pack_fail" ]; then
  echo 
  echo "WARNING: At least one missing package has no suitable installation candidate."
  echo "Press <Ctrl+C> to abort (5 sec)."
  sleep 5
fi

echo sun-java6-jdk shared/accepted-sun-dlj-v1-1 select true | sudo /usr/bin/debconf-set-selections
echo
if [ -n "$pack_arr" ]; then 
  echo "Installing missing packages:"
fi

for p in $pack_arr; do
  cmd="sudo $APTITUDE -y install $p" && run_cmd "$cmd" "$p"
done

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
    echo ". \"$JAVA_CONF\"" >> $OT_UI_CONF
  fi
fi

cd "$DIR"


#!/bin/bash
#
# Installs base packages for Ubuntu
# Author: Andreas Maunz
#
# Your installed packages are safe and will not be updated.
# A Java configuration is created and included in your '~.bashrc'.
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

# Dest
source ./config.sh
source ./utils.sh

# Pkgs
packs="lsb-release binutils gcc g++ gfortran wget hostname pwgen git-core raptor-utils r-base sun-java6-jdk libssl-dev zlib1g-dev libreadline-dev libmysqlclient-dev libcurl4-openssl-dev libxml2-dev libxslt1-dev libgsl0-dev sun-java6-jdk"

echo
echo "Base Packages:"

pack_arr=""
for p in $packs; do
  if $DPKG -s "$p" >/dev/null 2>&1; then
     printf "%25s%15s\n" "'$p'" "Y"
  else
     printf "%25s%15s\n" "'$p'" "N"
    pack_arr="$pack_arr $p"
  fi
done

if [ -n "$pack_arr" ]; then
  echo 
  echo "Checking availablity:"
  echo -n "Updating package indices:					"
  sudo $APTITUDE update -y >/dev/null 2>&1
  sudo $APTITUDE upgrade -y >/dev/null 2>&1
  echo "done."
fi

for p in $pack_arr; do
  if [ -n "`$APT_CACHE search $p`" ] ; then
     printf "%25s%15s\n" "'$p'" "Y"
  else
    printf "%25s%15s\n" "'$p'" "N"
    pack_fail="$pack_fail $p"
  fi
done

if [ -n "$pack_fail" ]; then
  echo 
  echo "WARNING: At least one missing package has no suitable installation candidate."
  echo "Press <Return> to continue or <Ctrl+C> to abort."
  read 
fi

echo
if [ -n $pack_arr ]; then 
  echo "Installing missing packages:"
fi

pack_fail=""
for p in $pack_arr; do
  echo -n "'$p':					"
  cmd="sudo $APTITUDE install $p" && run_cmd "$cmd" "$p"
done

if [ -n "$pack_fail" ]; then
  echo 
  echo "WARNING: At least one missing package could not be installed. Press <Return> to continue or <Ctrl+C> to abort."
  read 
fi

echo 
echo "Preparing JAVA:"
if [ ! -f $JAVA_CONF ]; then

  if [ ! -d "$JAVA_HOME" ]; then
    echo "Directory '$JAVA_HOME' does not exist! Aborting..."
    exit 1
  fi

  echo "if ! [[ \"\$JAVA_HOME\" =~ \"$JAVA_HOME\" ]]; then export JAVA_HOME=\"$JAVA_HOME\"; fi" >> "$JAVA_CONF"
  echo "if ! [[ \"\$PATH\" =~ \"$JAVA_HOME\" ]]; then export PATH=\"$JAVA_HOME:\$PATH\"; fi" >> "$JAVA_CONF"

  echo "Java configuration has been stored in '$JAVA_CONF'."
  if ! grep "$JAVA_CONF" $HOME/.bashrc >/dev/null 2>&1; then
    echo "source \"$JAVA_CONF\"" >> $HOME/.bashrc
  fi
fi


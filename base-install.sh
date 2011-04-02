#!/bin/sh
#
# Installs base packages for Ubuntu
# Author: Andreas Maunz
#
# Your installed packages are safe and will not be updated.
# A Java configuration is created and included in your '~.bashrc'.

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

touch $HOME/.bashrc

# Pkgs
packs="lsb-release binutils gcc g++ gfortran wget hostname pwgen git-core raptor-utils r-base sun-java6-jdk libssl-dev zlib1g-dev libreadline-dev libmysqlclient-dev libcurl4-openssl-dev libxml2-dev libxslt1-dev libgsl0-dev sun-java6-jdk libreadline5-dev libgfortran2 libblas-dev"

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
  sudo $APTITUDE update -y >/dev/null 2>&1
  sudo $APTITUDE upgrade -y >/dev/null 2>&1
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

  if [ ! -d "$JAVA_HOME" ]; then
    echo "Directory '$JAVA_HOME' does not exist! Aborting..."
    exit 1
  fi

  echo "if echo \"\$JAVA_HOME\" | grep -v \"$JAVA_HOME\">/dev/null 2>&1; then export JAVA_HOME=\"$JAVA_HOME\"; fi" >> "$JAVA_CONF"
  echo "if echo \"\$PATH\" | grep -v \"$JAVA_HOME\"; then export PATH=\"$JAVA_HOME:\$PATH\"; fi" >> "$JAVA_CONF"

  echo "Java configuration has been stored in '$JAVA_CONF'."
  if ! grep "$JAVA_CONF" $HOME/.bashrc >/dev/null 2>&1; then
    echo ". \"$JAVA_CONF\"" >> $HOME/.bashrc
  fi
fi

cd "$DIR"


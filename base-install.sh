#!/bin/bash
#
# Installs base packages for Ubuntu
# Author: Andreas Maunz
#

if [ "$(id -u)" = "0" ]; then
  echo "This script must not be run as root" 1>&2
  exit 1
fi

# Utils
APTITUDE="sudo `which aptitude`"
APT_CACHE="`which apt-cache`"
DCSS="sudo `which debconf-set-selections`"
DPKG="`which dpkg`"

if [ ! -e $APTITUDE ]; then
  echo "Aptitude missing. Install aptitude first." 1>&2
  exit 1
fi

# Dest
source ./config.sh

# Pkgs
packs="lsb-release binutils gcc g++ gfortran wget hostname pwgen git-core raptor-utils r-base sun-java6-jdk libssl-dev zlib1g-dev libreadline-dev libmysqlclient-dev libcurl4-openssl-dev libxml2-dev libxslt1-dev libgsl0-dev sun-java6-jdk"

echo "This installs missing base packages for Opentox-ruby on Ubuntu"
echo "Your installed packages are safe and will not be updated."
echo "A Java configuration is created and you are given the option to have it included in your '~.bashrc'."
echo "Press <Return> to continue or <Ctrl+C> to abort."
read

echo "Checking for installed packages: "
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
  echo "Checking availablity of missing packages..."
  echo -n "Updating package indices:					"
  $APTITUDE update -y >/dev/null 2>&1
  $APTITUDE upgrade -y >/dev/null 2>&1
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
echo "Installing missing packages, please wait..."
pack_fail=""
for p in $pack_arr; do
  echo -n "'$p':					"
  if $APTITUDE install "$p" -y >/dev/null 2>&1; then
    printf "%25s%15s\n" "'$p'" "DONE"
  else
    printf "%25s%15s\n" "'$p'" "FAIL"
  fi
done

if [ -n "$pack_fail" ]; then
  echo 
  echo "WARNING: At least one missing package could not be installed. Press <Return> to continue or <Ctrl+C> to abort."
  read 
fi

echo 
echo "Preparing JAVA..."
if [ ! -f $JAVA_CONF ]; then

  echo -n "Please provide a path for JAVA_HOME (hint: type echo \$JAVA_HOME as normal user): "
  read USER_SUBMITTED_JAVA_HOME
  JAVA_HOME="$USER_SUBMITTED_JAVA_HOME"

  if [ ! -d "$JAVA_HOME" ]; then
    echo "Directory '$JAVA_HOME' does not exist! Aborting..."
    exit 1
  fi

  echo "JAVA_HOME=$JAVA_HOME" >> "$JAVA_CONF"
  echo "PATH=$JAVA_HOME:\$PATH" >> "$JAVA_CONF"

  echo "Java configuration has been stored in '$JAVA_CONF'."
  echo -n "Answer 'y' if Java configuration should be linked to your .bashrc: "
  read ANSWER_JAVA_CONF
  if [ $ANSWER_JAVA_CONF = "y" ]; then
    echo "source \"$JAVA_CONF\"" >> $HOME/.bashrc
  fi

else
  echo "It seems JAVA is already configured ('$JAVA_CONF' exists)."
fi

echo
echo "Installation finished."

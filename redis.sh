#!/bin/sh

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
WGET="`which wget`"
if [ ! -e "$WGET" ]; then
  echo "'wget' missing. Install 'wget' first. Aborting..."
  exit 1
fi

source ./config.sh

echo "This installs Redis."
echo "Press <Return> to continue, or <Ctrl+C> to abort."
read

DIR=`pwd`

REDIS_DONE=false
mkdir "$REDIS_DEST" >/dev/null 2>&1
if [ ! -d "$REDIS_DEST" ]; then
  echo "Install directory '$REDIS_DEST' is not available! Aborting..."
  exit 1
else
  if ! rmdir "$REDIS_DEST" >/dev/null 2>&1; then # if not empty this will fail
    echo "Install directory '$REDIS_DEST' is not empty. Skipping kernlab installation..."
    REDIS_DONE=true
  else
    mkdir "$REDIS_DEST" >/dev/null 2>&1
  fi
fi

if ! $REDIS_DONE; then
  echo  "Need root password: "
  echo "vm.overcommit_memory = 1" | sudo tee -a /etc/sysctl.conf

  cd $HOME
  $WGET -O - "http://redis.googlecode.com/files/redis-$REDIS_VER.tar.gz" | tar zxv
  cd $REDIS_DEST 
  if ! make; then
    echo "Build failed! Aborting..."
    exit 1
  fi
  echo "daemonize yes" > $REDIS_SERVER_CONF
  echo "dir `pwd`" >> $REDIS_SERVER_CONF

  echo 
  echo "Preparing Redis..."
  if [ ! -f $REDIS_CONF ]; then
    echo "PATH=$REDIS_DEST/bin:\$PATH" >> "$REDIS_CONF"
    echo "Redis configuration has been stored in '$REDIS_CONF'."
    echo -n "Decide if Redis configuration should be linked to your .bashrc ('y/n'): "
    read ANSWER_REDIS_CONF
    if [ $ANSWER_REDIS_CONF = "y" ]; then
      echo "source \"$REDIS_CONF\"" >> $HOME/.bashrc
    fi
  else
    echo "It seems Redis is already configured ('$RUBY_CONF' exists)."
  fi

fi

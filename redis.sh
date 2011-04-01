#!/bin/bash
#
# Installs Redis.
# Author: Christoph Helma, Andreas Maunz.
#

source ./utils.sh

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

LOG="/tmp/`basename $0`-log.txt"

echo "This installs Redis."
echo "Log file is '$LOG'."

DIR=`pwd`

REDIS_DONE=false
mkdir "$REDIS_DEST" >/dev/null 2>&1
if [ ! -d "$REDIS_DEST" ]; then
  echo "Install directory '$REDIS_DEST' is not available! Aborting..."
  exit 1
else
  if ! rmdir "$REDIS_DEST" >/dev/null 2>&1; then # if not empty this will fail
    echo "Install directory '$REDIS_DEST' is not empty. Skipping Redis installation..."
    REDIS_DONE=true
  else
    mkdir "$REDIS_DEST" >/dev/null 2>&1
  fi
fi

if ! $REDIS_DONE; then
  echo "vm.overcommit_memory = 1" | sudo tee -a /etc/sysctl.conf >>$LOG 2>&1

  cd $PREFIX
  URI="http://redis.googlecode.com/files/redis-$REDIS_VER.tar.gz"
  if ! [ -d "redis-$REDIS_VER" ]; then
    cmd="$WGET $URI" && run_cmd "$cmd" "Download"
    cmd="tar zxf redis-$REDIS_VER.tar.gz" && run_cmd "$cmd" "Unpack"
  fi
  cd redis-$REDIS_VER >>$LOG 2>&1
  cmd="make" && run_cmd "$cmd" "Make"

  if ! grep "daemonize yes" $REDIS_SERVER_CONF >>$LOG 2>&1 ; then 
    echo "daemonize yes" > $REDIS_SERVER_CONF 2>$LOG
  fi

  if ! grep "dir `pwd`" $REDIS_SERVER_CONF >>$LOG 2>&1 ; then 
    echo "dir `pwd`" >> $REDIS_SERVER_CONF 2>$LOG
  fi
fi

cd "$DIR"

if [ ! -f $REDIS_CONF ]; then
  echo "export PATH=$REDIS_DEST/src:\$PATH" >> "$REDIS_CONF"
  echo "Redis configuration has been stored in '$REDIS_CONF'."

  if ! grep "source \"$REDIS_CONF\"" $HOME/.bashrc; then
    echo "source \"$REDIS_CONF\"" >> $HOME/.bashrc
  fi

fi

cd "$DIR"

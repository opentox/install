#!/bin/bash
#
# Installs Redis.
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
source ./utils.sh
LOG="/tmp/`basename $0`-log.txt"

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
    echo "Install directory '$REDIS_DEST' is not empty. Skipping Redis installation..."
    REDIS_DONE=true
  else
    mkdir "$REDIS_DEST" >/dev/null 2>&1
  fi
fi

if ! $REDIS_DONE; then
  echo  "Need root password: "
  echo "vm.overcommit_memory = 1" | sudo tee -a /etc/sysctl.conf >>$LOG 2>&1

  cd $HOME
  URI="http://redis.googlecode.com/files/redis-$REDIS_VER.tar.gz"
  if ! $WGET -O - "$URI" | tar zxv >>$LOG 2>&1; then
    printf "%25s%15s\n" "'Download'" "FAIL"
  fi
  printf "%25s%15s\n" "'Download'" "DONE"

  cd $REDIS_DEST >>$LOG 2>&1
  if ! make>>$LOG 2>&1; then
    printf "%25s%15s\n" "'Make'" "FAIL"
    exit 1
  fi
  printf "%25s%15s\n" "'Make'" "DONE"

  if ! grep "daemonize yes" $REDIS_SERVER_CONF >>$LOG 2>&1 ; then 
    echo "daemonize yes" > $REDIS_SERVER_CONF 2>$LOG
  fi

  if ! grep "dir `pwd`" $REDIS_SERVER_CONF >>$LOG 2>&1 ; then 
    echo "dir `pwd`" >> $REDIS_SERVER_CONF 2>$LOG
  fi
fi

echo 
echo "Preparing Redis..."
if [ ! -f $REDIS_CONF ]; then
  echo "export PATH=$REDIS_DEST/src:\$PATH" >> "$REDIS_CONF"
  echo "Redis configuration has been stored in '$REDIS_CONF'."

  if ! grep "source \"$REDIS_CONF\"" $HOME/.bashrc; then
    echo "source \"$REDIS_CONF\"" >> $HOME/.bashrc
  fi

else
  echo "It seems Redis is already configured ('$RUBY_CONF' exists)."
fi

cd "$DIR"
echo
echo "Redis installation finished."

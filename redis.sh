#!/bin/sh
#
# Installs Redis.
# Author: Christoph Helma, Andreas Maunz.
#

. "`pwd`/utils.sh"
DIR=`pwd`

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

echo
echo "Redis ('$LOG'):"


REDIS_DONE=false
mkdir "$REDIS_DEST" >/dev/null 2>&1
if [ ! -d "$REDIS_DEST" ]; then
  echo "Install directory '$REDIS_DEST' is not available! Aborting..."
  exit 1
else
  if ! rmdir "$REDIS_DEST" >/dev/null 2>&1; then # if not empty this will fail
    REDIS_DONE=true
  fi
fi

if ! $REDIS_DONE; then
  echo "vm.overcommit_memory = 1" | sudo tee -a /etc/sysctl.conf >>$LOG 2>&1

  cd $OT_PREFIX
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

  if ! grep "save 900 1" $REDIS_SERVER_CONF >>$LOG 2>&1 ; then 
    echo "save 900 1" >> $REDIS_SERVER_CONF 2>$LOG
  fi
fi

if [ ! -f $REDIS_CONF ]; then
  echo "if ! echo \"\$PATH\" | grep \"$REDIS_DEST\">/dev/null 2>&1; then export PATH=$REDIS_DEST/src:\$PATH; fi" >> "$REDIS_CONF"
  echo "Redis configuration has been stored in '$REDIS_CONF'."

  if ! grep ". \"$REDIS_CONF\"" $OT_UI_CONF; then
    echo ". \"$REDIS_CONF\"" >> $OT_UI_CONF
  fi

fi

cd "$DIR"

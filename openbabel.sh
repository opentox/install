#!/bin/sh
#
# Installs Openbabel.
# A configuration file is created and included in your '$OT_UI_CONF'.
# Author: Christoph Helma, Andreas Maunz.
#

. "`pwd`/utils.sh"
DIR="`pwd`"

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
CMAKE="`which cmake`"
if [ ! -e "$CMAKE" ]; then
  echo "'cmake' missing. Install 'cmake' first. Aborting..."
  exit 1
fi

# Pkg
LOG="$HOME/tmp/`basename $0`-log.txt"

echo
echo "Openbabel ('$OB_DEST', '$LOG'):"


mkdir "$OB_DEST" >/dev/null 2>&1
if [ ! -d "$OB_DEST" ]; then
  echo "Install directory '$OB_DEST' is not available! Aborting..."
  exit 1
else
  if ! rmdir "$OB_DEST" >/dev/null 2>&1; then # if not empty this will fail
    OB_DONE=true
  fi
fi

if [ ! $OB_DONE ]; then
  cd "$HOME/tmp">>$LOG 2>/dev/null
  URI="http://downloads.sourceforge.net/project/openbabel/openbabel/$OB_NUM_VER/$OB_VER.tar.gz?use_mirror=kent"
  if ! [ -d "$HOME/tmp/$OB_VER" ]; then 
    cmd="$WGET $URI" && run_cmd "$cmd" "Download"
    cmd="tar zxf $OB_VER.tar.gz?use_mirror=kent $OB_VER"  && run_cmd "$cmd" "Unpack"
  fi
  cd "$HOME/tmp/$OB_VER">>$LOG 2>/dev/null
  cmd="$CMAKE -DCMAKE_INSTALL_PREFIX=$OB_DEST" && run_cmd "$cmd" "Configure"
  cmd="make -j2" && run_cmd "$cmd" "Make"
  cmd="make install" && run_cmd "$cmd" "Install"
fi

if [ ! -f "$OB_CONF" ]; then

  echo "if echo \"\$PATH\" | grep -v \"$OB_DEST\">/dev/null 2>&1; then export PATH=\"$OB_DEST/bin:\$PATH\"; fi" >> "$OB_CONF"
  echo "if echo \"\$LD_LIBRARY_PATH\" | grep -v \"$OB_DEST\">/dev/null 2>&1; then export LD_LIBRARY_PATH=\"$OB_DEST/lib:\$LD_LIBRARY_PATH\"; fi" >> "$OB_CONF"
  echo "if ! [ -d \"$OB_DEST\" ]; then echo \"\$0: '$OB_DEST' is not a directory!\"; fi" >> "$OB_CONF"

  echo "if [ -z \"\$BABEL_LIBDIR\" ]; then export BABEL_LIBDIR=\"$OB_DEST/lib/openbabel/$OB_NUM_VER\"; fi" >> "$OB_CONF"
  echo "if ! [ -d \"\$BABEL_LIBDIR\" ]; then echo \"\$0: '\$BABEL_LIBDIR' is not a directory!\"; fi" >> "$OB_CONF"

  echo "if [ -z \"\$BABEL_DATADIR\" ]; then export BABEL_DATADIR=\"$OB_DEST/share/openbabel/$OB_NUM_VER\"; fi" >> "$OB_CONF"
  echo "if ! [ -d \"\$BABEL_DATADIR\" ]; then echo \"\$0: '\$BABEL_DATADIR' is not a directory!\"; fi" >> "$OB_CONF"

  echo "Openbabel configuration has been stored in '$OB_CONF'."
  if ! grep "$OB_CONF" $OT_UI_CONF >/dev/null 2>&1 ; then
    echo ". \"$OB_CONF\"" >> $OT_UI_CONF
  fi

fi

cd "$DIR"

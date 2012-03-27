#!/bin/sh

# Installs Openbabel.
# Author: Christoph Helma, Andreas Maunz.
# A configuration file is created and included in your 'OT_UI_CONF' (see config.sh).

. ./utils.sh
DIR=`pwd`
OB_DWL="http://downloads.sourceforge.net/sourceforge/openbabel/$OB_NUM_VER/$OB_VER.tar.gz"

[ "`id -u`" = "0" ] && echo "This script must be run as non-root." 1>&2 && exit 1

# check utils
utils="curl cmake"
for u in $utils; do
  eval `echo $u | tr "[:lower:]" "[:upper:]"`=`which $u` || (echo "'$u' missing. Install '$u' first." 1>&2 && exit 1)
done

# check openbabel
LOG="$OT_PREFIX/tmp/`basename $0`.log"
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
  cd "$OT_PREFIX/tmp">>$LOG 2>/dev/null
  ([ -d "$OT_PREFIX/tmp/$OB_VER" ] || $CURL -L -d use_mirror=netcologne $OB_DWL 2>/dev/null | tar zx) && cd $OB_VER
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

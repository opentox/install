#!/bin/sh
#
# Installs Openbabel.
# A configuration file is created and included in your '~.bashrc'.
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

# Pkg
LOG="/tmp/`basename $0`-log.txt"

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
  cd "/tmp">>$LOG 2>/dev/null
  URI="http://downloads.sourceforge.net/project/openbabel/openbabel/$OB_NUM_VER/$OB_VER.tar.gz?use_mirror=kent"
  if ! [ -d "/tmp/$OB_VER" ]; then 
    cmd="$WGET $URI" && run_cmd "$cmd" "Download"
    cmd="tar zxf $OB_VER.tar.gz?use_mirror=kent $OB_VER"  && run_cmd "$cmd" "Unpack"
  fi
  cd "/tmp/$OB_VER">>$LOG 2>/dev/null

  cmd="./configure --prefix=$OB_DEST" && run_cmd "$cmd" "Configure"
  cmd="make" && run_cmd "$cmd" "Make"
  cmd="make install" && run_cmd "$cmd" "Install"
fi

if [ ! -f "$OB_CONF" ]; then

  echo "if ! [[ \"\$PATH\" =~ \"$OB_DEST\" ]]; then export PATH=\"$OB_DEST/bin:\$PATH\"; fi" >> "$OB_CONF"
  echo "if ! [[ \"\$LD_LIBRARY_PATH\" =~ \"$OB_DEST\" ]]; then export LD_LIBRARY_PATH=\"$OB_DEST/lib:\$LD_LIBRARY_PATH\"; fi" >> "$OB_CONF"
  echo "if [ -z \"\$BABEL_LIBDIR\" ]; then export BABEL_LIBDIR=\"$OB_DEST/lib/openbabel/2.3.0\"; fi" >> "$OB_CONF"
  echo "if [ -z \"\$BABEL_DATADIR\" ]; then export BABEL_DATADIR=\"$OB_DEST/share/openbabel/2.3.0\"; fi" >> "$OB_CONF"
  echo "if [ -z \"\$RUBYLIB\" ]; then export RUBYLIB=\"$OB_DEST_BINDINGS\"; fi" >> "$RUBY_CONF"

  echo "Openbabel configuration has been stored in '$OB_CONF'."
  if ! grep "$OB_CONF" $HOME/.bashrc >/dev/null 2>&1 ; then
    echo ". \"$OB_CONF\"" >> $HOME/.bashrc
  fi

fi

echo "Bindings:"
OB_DONE=false
. "$HOME/.bashrc"
mkdir "$OB_DEST_BINDINGS">/dev/null 2>&1
if [ ! -d "$OB_DEST_BINDINGS" ]; then
  echo "Install directory '$OB_DEST_BINDINGS' is not available! Aborting..."
  exit 1
else
  if [ "`ls $OB_DEST_BINDINGS | wc -l`" -gt 0 ]; then
    OB_DONE=true
  fi
fi

if ! $OB_DONE ; then
  cd "/tmp/$OB_VER/scripts/ruby/"
  cmd="ruby extconf.rb --with-openbabel-include=$OB_DEST/include/openbabel-2.0 --with-openbabel-lib=$OB_DEST/lib" && run_cmd "$cmd" "Code"
  cmd="make" && run_cmd "$cmd" "Make"
  cmd="cp openbabel.so $OB_DEST_BINDINGS" && run_cmd "$cmd" "Install"
fi

cd "$DIR"



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

  cmd="./configure --prefix=$OB_DEST" && run_cmd "$cmd" "Configure"
  cmd="make" && run_cmd "$cmd" "Make"
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

  echo "if echo \"\$RUBYLIB\" | grep -v \"$OB_DEST_BINDINGS\">/dev/null 2>&1; then export RUBYLIB=\"$OB_DEST_BINDINGS:\$RUBYLIB\"; fi" >> "$RUBY_CONF"
  echo "if ! [ -d \"$OB_DEST_BINDINGS\" ]; then echo \"\$0: '$OB_DEST_BINDINGS' is not a directory!\"; fi" >> "$RUBY_CONF"

  echo "Openbabel configuration has been stored in '$OB_CONF'."
  if ! grep "$OB_CONF" $OT_UI_CONF >/dev/null 2>&1 ; then
    echo ". \"$OB_CONF\"" >> $OT_UI_CONF
  fi

fi

echo "Bindings:"
OB_DONE=false
. "$OT_UI_CONF"
mkdir -p "$OB_DEST_BINDINGS">/dev/null 2>&1
if [ ! -d "$OB_DEST_BINDINGS" ]; then
  echo "Install directory '$OB_DEST_BINDINGS' is not available! Aborting..."
  exit 1
else
  if [ "`ls $OB_DEST_BINDINGS | wc -l`" -gt 0 ]; then
    OB_DONE=true
  fi
fi

if ! $OB_DONE ; then
 OB_SRC_DIR="$HOME/tmp/$OB_VER/scripts/ruby/"
 cd "$OB_SRC_DIR"
 cmd="ruby extconf.rb --with-openbabel-include=$OB_DEST/include/openbabel-2.0 --with-openbabel-lib=$OB_DEST/lib" && run_cmd "$cmd" "Code"
 cmd="make" && run_cmd "$cmd" "Make"
 cmd="cp openbabel.so $OB_DEST_BINDINGS" && run_cmd "$cmd" "Install"
 cmd="ln -sf $OB_DEST_BINDINGS/openbabel.so $RUBY_DEST/lib/ruby/site_ruby/1.8/`uname -m`-linux/" && run_cmd "$cmd" "Link"
 cd "$DIR"
 . "`pwd`/utils.sh"
 cmd="ruby test-ob-rb.rb" && run_cmd "$cmd" "Load"
fi


#!/bin/bash
#
# Installs Openbabel.
# Pass an Openbabel version string as first argument to install a specific version (blank for default).
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

# Pkg
source ./config.sh
source ./utils.sh
LOG="/tmp/`basename $0`-log.txt"

echo "This installs Openbabel."
echo "Your installation directory is '$OB_DEST'."
echo "A configuration file is created and you are given the option to have it included in your '~.bashrc'."
echo "Log file is '$LOG'."
echo "Press <Return> to continue, or <Ctrl+C> to abort."
read

DIR="`pwd`"

mkdir "$OB_DEST" >/dev/null 2>&1
if [ ! -d "$OB_DEST" ]; then
  echo "Install directory '$OB_DEST' is not available! Aborting..."
  exit 1
else
  if ! rmdir "$OB_DEST" >/dev/null 2>&1; then # if not empty this will fail
    echo "Install directory '$OB_DEST' is not empty. Skipping openbabel base installation..."
    OB_DONE=true
  fi
fi

if [ ! $OB_DONE ]; then
  cd /tmp
  URI="http://downloads.sourceforge.net/project/openbabel/openbabel/$OB_NUM_VER/$OB_VER.tar.gz?use_mirror=kent"
  if ! $WGET -O - "$URI" 2>>$LOG | tar zxv >>$LOG 2>&1; then
    printf "%25s%15s\n" "'Download'" "FAIL"
    exit 1
  fi
  printf "%25s%15s\n" "'Download'" "DONE"
  cd "/tmp/$OB_VER"

  if ! ./configure --prefix="$OB_DEST" >>$LOG 2>&1; then
    printf "%25s%15s\n" "'Configure'" "FAIL"
    exit 1
  fi
  printf "%25s%15s\n" "'Configure'" "DONE"

  if ! make >>$LOG 2>&1; then 
    printf "%25s%15s\n" "'Make'" "FAIL"
    exit 1
  fi
  printf "%25s%15s\n" "'Make'" "DONE"

  if ! make install >>$LOG 2>&1; then 
    printf "%25s%15s\n" "'Install'" "FAIL"
    exit 1
  fi
  printf "%25s%15s\n" "'Install'" "DONE"
fi



OB_DONE=false
mkdir "$OB_DEST_BINDINGS">/dev/null 2>&1
if [ ! -d "$OB_DEST_BINDINGS" ]; then
  echo "Install directory '$OB_DEST_BINDINGS' is not available! Aborting..."
  exit 1
else
  if [ "`ls $OB_DEST_BINDINGS | wc -l`" -gt 0 ]; then
    echo "Install directory '$OB_DEST_BINDINGS' is not empty. Skipping Openbabel Binding installation..."
    OB_DONE=true
  fi
fi

if ! $OB_DONE ; then
  cd "/tmp/$OB_VER/scripts/ruby/"

  if ! ruby extconf.rb --with-openbabel-include="$OB_DEST/include/openbabel-2.0" >>$LOG 2>&1; then 
    printf "%25s%15s\n" "'Bindings: Code'" "FAIL"
    exit 1
  fi
  printf "%25s%15s\n" "'Bindings: Code'" "DONE"
  
  if ! make >>$LOG 2>&1; then
    printf "%25s%15s\n" "'Bindings: Make'" "FAIL"
    exit 1
  fi
  printf "%25s%15s\n" "'Bindings: Make'" "DONE"

  if ! cp openbabel.so $OB_DEST_BINDINGS >>$LOG 2>&1; then
    printf "%25s%15s\n" "'Bindings: Install'" "FAIL"
    exit 1
  fi
  printf "%25s%15s\n" "'Bindings: Install'" "DONE"
  
fi


cd "$DIR"

echo 
echo "Preparing Openbabel..."
if [ ! -f $OB_CONF ]; then
  echo "if ! [[ \"\$PATH\" =~ \"$OB_DEST\" ]]; then export PATH=\"$OB_DEST/bin:\$PATH\"; fi" >> "$OB_CONF"
  echo "if ! [[ \"\$LD_LIBRARY_PATH\" =~ \"$OB_DEST\" ]]; then export LD_LIBRARY_PATH=\"$OB_DEST/lib:\$LD_LIBRARY_PATH\"; fi" >> "$OB_CONF"
  echo "if [ -z \"\$BABEL_LIBDIR\" ]; then export BABEL_LIBDIR=\"$OB_DEST/lib/openbabel/2.3.0\"; fi" >> "$OB_CONF"
  echo "if [ -z \"\$BABEL_DATADIR\" ]; then export BABEL_DATADIR=\"$OB_DEST/share/openbabel/2.3.0\"; fi" >> "$OB_CONF"
  echo "if [ -z \"\$RUBYLIB\" ]; then export RUBYLIB=\"$OB_DEST_BINDINGS\"; fi" >> "$RUBY_CONF"
  echo "Openbabel configuration has been stored in '$OB_CONF'."
  echo -n "Decide if Openbabel configuration should be linked to your .bashrc ('y/n'): "
  read ANSWER_OB_CONF
  if [ $ANSWER_OB_CONF = "y" ]; then
    echo "source \"$OB_CONF\"" >> $HOME/.bashrc
  fi
else
  echo "It seems Openbabel is already configured ('$OB_CONF' exists)."
fi

echo
echo "Openbabel Installation finished."

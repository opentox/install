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
VER="2.2.3"
OBVER="openbabel-$VER"
PREFIX="$HOME/$OBVER"
if [ -n "$1" ]; then
  PREFIX="$1"
fi
PREFIX_BINDINGS="$HOME/openbabel-ruby-install"

# Dest
OB_CONF=$HOME/.bash_OB_ot
RUBY_CONF=$HOME/.bash_ruby_ot

mkdir "$PREFIX" >/dev/null 2>&1
if [ ! -d "$PREFIX" ]; then
  echo "Install directory '$PREFIX' is not available! Aborting..."
  exit 1
else
  if ! rmdir "$PREFIX" >/dev/null 2>&1; then # if not empty this will fail
    echo "Install directory '$PREFIX' is not empty. Skipping Openbabel installation..."
    OB_DONE=true
  fi
fi

DIR="`pwd`"
if [ ! $OB_DONE ]; then
  echo "This installs Openbabel Enterprise edition."
  echo "Your installation directory is '$PREFIX'."
  echo "A configuration file is created and you are given the option to have it included in your '~.bashrc'."
  echo "Press <Return> to continue, or <Ctrl+C> to abort."
  read
  cd /tmp
  if ! $WGET -O - "http://downloads.sourceforge.net/project/openbabel/openbabel/$VER/$OBVER.tar.gz?use_mirror=kent" | tar zxv >/dev/null 2>&1; then
    echo "Download failed! Aborting..."
    exit 1
  fi
  cd "/tmp/$OBVER"
 ./configure --prefix="$PREFIX"
  make
  make install
fi

echo
echo "Openbabel installation done."
echo "Next ruby bindings should be installed."
echo "Press <Return> to continue, or <Ctrl+C> to abort."
echo -n "Enter 's' to skip this step: "
read RBB_SKIP 
if [ "$RBB_SKIP" != "s" ]; then

  mkdir "$PREFIX_BINDINGS">/dev/null 2>&1
  if [ ! -d "$PREFIX_BINDINGS" ]; then
    echo "Install directory '$PREFIX_BINDINGS' is not available! Aborting..."
    exit 1
  else
    if [ "`ls $PREFIX_BINDINGS | wc -l`" -gt 0 ]; then
      echo "Install directory '$PREFIX_BINDINGS' is not empty. Skipping Openbabel Binding installation..."
      OB_DONE=true
    fi
  fi

  if ! $OB_DONE ; then
    cd scripts/ruby/
    ruby extconf.rb --with-openbabel-include="$PREFIX/include/openbabel-2.0"
    if make ; then
      cp openbabel.so $PREFIX_BINDINGS
    else
      echo
      echo "Make failed! Aborting..."
      exit 1
    fi
  fi
fi
cd "$DIR"

echo 
echo "Preparing Openbabel..."
if [ ! -f $OB_CONF ]; then
  echo "PATH=$PREFIX/bin:\$PATH" >> "$OB_CONF"
  echo "if [ -z \"$LD_LIBRARY_PATH\" ]; then \
          export LD_LIBRARY_PATH=\"$PREFIX/lib\"; \
        else \
          export LD_LIBRARY_PATH=\"$PREFIX/lib:$LD_LIBRARY_PATH\"; \
        fi" >> "$OB_CONF"
  echo "if [ -z \"$BABEL_LIBDIR\" ]; then \
          export BABEL_LIBDIR=\"$PREFIX/lib/openbabel/2.3.0\"; \
        fi" >> "$OB_CONF"
  echo "if [ -z \"$BABEL_DATADIR\" ]; then \
          export BABEL_DATADIR=\"$PREFIX/share/openbabel/2.3.0\"; \
         fi" >> "$OB_CONF"
  echo "if [ -z \"$RUBYLIB\" ]; then \
          export RUBYLIB=\"$PREFIX_BINDINGS\"; \
        fi" >> "$RUBY_CONF"

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

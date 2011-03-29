#!/bin/bash
#
# Installs Ruby enterprise edition and passenger gem.
# Pass a ruby version string as first argument to install a specific version (blank for default).
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
if [ -n "$1" ]; then
  RUBY_DEST="$1"
fi

echo "This installs Ruby Enterprise edition."
echo "Your installation directory is '$RUBY_DEST'."
echo "A configuration file is created and you are given the option to have it included in your '~.bashrc'."
echo "Press <Return> to continue, or <Ctrl+C> to abort."
read

DIR="`pwd`"

mkdir "$RUBY_DEST" >/dev/null 2>&1
if [ ! -d "$RUBY_DEST" ]; then
  echo "Install directory '$RUBY_DEST' is not available! Aborting..."
  exit 1
else
  if ! rmdir "$RUBY_DEST" >/dev/null 2>&1; then # if not empty this will fail
    echo "Install directory '$RUBY_DEST' is not empty. Skipping Ruby installation..."
    RUBY_DONE=true
  fi
fi

if [ ! $RUBY_DONE ]; then
  cd /tmp
  if ! $WGET -O - "http://rubyenterpriseedition.googlecode.com/files/$RUBY_VER.tar.gz" | tar zxv >/dev/null 2>&1 ; then
    echo "Download failed! Aborting..."
    exit 1
  fi
  sh /tmp/$RUBY_VER/installer  --dont-install-useful-gems --no-dev-docs --auto="$RUBY_DEST"
fi

echo
echo "Ruby installation done."
echo "Next 'Passenger' should be installed."
echo "This will modify your '~/.gemrc'."
echo "Press <Return> to continue, or <Ctrl+C> to abort."
echo -n "Enter 's' to skip this step: "
read PASSENGER_SKIP 
if [ "$PASSENGER_SKIP" != "s" ]; then
  export PATH="$RUBY_DEST/bin:$PATH"
  gem sources -a "http://gemcutter.org "
  gem sources -r "http://rubygems.org/"
  echo "gem: --no-ri --no-rdoc" | tee -a $HOME/.gemrc
  gem install passenger
fi
cd "$DIR"

echo 
echo "Preparing RUBY..."
if [ ! -f $RUBY_CONF ]; then
  echo "export PATH=$RUBY_DEST/bin:\$PATH" >> "$RUBY_CONF"
  echo "Ruby configuration has been stored in '$RUBY_CONF'."
  echo -n "Decide if Ruby configuration should be linked to your .bashrc ('y/n'): "
  read ANSWER_RUBY_CONF
  if [ $ANSWER_RUBY_CONF = "y" ]; then
    echo "source \"$RUBY_CONF\"" >> $HOME/.bashrc
  fi
else
  echo "It seems RUBY is already configured ('$RUBY_CONF' exists)."
fi

echo
echo "Ruby Installation finished."

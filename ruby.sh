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
RUBYVER="ruby-enterprise-1.8.7-2011.03"
PREFIX="$HOME/$RUBYVER"
if [ -n "$1" ]; then
  PREFIX="$1"
fi

# Dest
RUBY_CONF=$HOME/.bash_ruby_ot

mkdir "$PREFIX" >/dev/null 2>&1
if [ ! -d "$PREFIX" ]; then
  echo "Install directory '$PREFIX' is not available! Aborting..."
  exit 1
else
  if ! rmdir "$PREFIX" >/dev/null 2>&1; then # if not empty this will fail
    echo "Install directory '$PREFIX' is not empty. Skipping Ruby installation..."
    RUBY_DONE=true
  fi
fi

if [ ! $RUBY_DONE ]; then
  echo "This installs Ruby Enterprise edition."
  echo "Your installation directory is '$PREFIX'."
  echo "A configuration file is created and you are given the option to have it included in your '~.bashrc'."
  echo "Press <Return> to continue, or <Ctrl+C> to abort."
  DIR="`pwd`"
  cd /tmp
  if ! $WGET -O - "http://rubyenterpriseedition.googlecode.com/files/$RUBYVER.tar.gz" | tar zxv >/dev/null 2>&1 ; then
    echo "Download failed! Aborting..."
    exit 1
  fi
  sh /tmp/$RUBYVER/installer  --dont-install-useful-gems --no-dev-docs --auto="$PREFIX"
fi

echo
echo "Ruby installation done."
echo "Next 'Passenger' should be installed."
echo "This will modify your '~/.gemrc'."
echo "Press <Return> to continue, or <Ctrl+C> to abort."
echo -n "Enter 's' to skip this step: "
read PASSENGER_SKIP 
if [ "$PASSENGER_SKIP" != "s" ]; then
  export PATH="$PREFIX/bin:$PATH"
  gem sources -a "http://gemcutter.org "
  gem sources -r "http://rubygems.org/"
  echo "gem: --no-ri --no-rdoc" | tee -a $HOME/.gemrc
  gem install passenger
fi
cd "$DIR"

echo 
echo "Preparing RUBY..."
if [ ! -f $RUBY_CONF ]; then
  echo "PATH=$PREFIX/bin:\$PATH" >> "$RUBY_CONF"
  echo "Ruby configuration has been stored in '$RUBY_CONF'."
  echo -n "Decide if Ruby configuration should be linked to your .bashrc ('y/n'): "
  read ANSWER_JAVA_CONF
  if [ $ANSWER_JAVA_CONF = "y" ]; then
    echo "source \"$RUBY_CONF\"" >> $HOME/.bashrc
  fi
else
  echo "It seems RUBY is already configured ('$RUBY_CONF' exists)."
fi

echo
echo "Ruby Installation finished."

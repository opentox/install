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
source ./utils.sh
LOG="/tmp/`basename $0`-log.txt"


echo "This installs Ruby Enterprise edition."
echo "Your installation directory is '$RUBY_DEST'."
echo "A configuration file is created and you are given the option to have it included in your '~.bashrc'."
echo "When compilation fails, see '$LOG' for details."
echo -n "Press <Return> to continue, or <Ctrl+C> to abort."
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
  URI="http://rubyenterpriseedition.googlecode.com/files/$RUBY_VER.tar.gz"
  if ! $WGET -O - "$URI" | tar zxv >>$LOG 2>&1 ; then
  printf "%25s%15s\n" "'Download'" "FAIL"
    exit 1
  fi
  printf "%25s%15s\n" "'Download'" "DONE"
  if ! sh /installer  --dont-install-useful-gems --no-dev-docs --auto="$RUBY_DEST" >>$LOG 2>&1 ; then
      printf "%25s%15s\n" "'Install'" "FAIL"
      exit 1
  fi
  printf "%25s%15s\n" "'Install'" "DONE"
fi

cd "$DIR"

echo 
echo "Preparing RUBY..."

if ! [ -f "$RUBY_CONF" ]; then

  echo "export PATH=$RUBY_DEST/bin:\$PATH" >> "$RUBY_CONF"

  echo "Ruby configuration has been stored in '$RUBY_CONF'."
  if ! grep "$RUBY_CONF" $HOME/.bashrc >/dev/null 2>&1 ; then
    echo "source \"$RUBY_CONF\"" >> $HOME/.bashrc
  fi

else
  echo "It seems RUBY is already configured ('$RUBY_CONF' exists)."
fi





echo
echo "Ruby installation done."
echo "Next 'Passenger' should be installed."
echo "This will modify your '~/.gemrc'."
echo "Press <Return> to continue, or <Ctrl+C> to abort."
echo -n "Enter 's' to skip this step: "
read PASSENGER_SKIP 

source "$RUBY_CONF"
GEM="`which gem`"
if [ ! -e "$GEM" ]; then
  echo "'gem' missing. Install 'gem' first. Aborting..."
  exit 1
fi

if [ "$PASSENGER_SKIP" != "s" ]; then
  export PATH="$RUBY_DEST/bin:$PATH"
  if ! $GEM sources -a "http://gemcutter.org " >>$LOG 2>&1 ; then
    printf "%25s%15s\n" "'Add Gemcutter'" "FAIL"
    exit 1
  fi
  printf "%25s%15s\n" "'Add Gemcutter'" "DONE"
  if ! $GEM sources -r "http://rubygems.org/" >>$LOG 2>&1 ; then
    printf "%25s%15s\n" "'Add Rubygems'" "FAIL"
    exit 1
  fi
  printf "%25s%15s\n" "'Add Rubygems'" "DONE"
  GEMCONF="gem: --no-ri --no-rdoc"
  if ! grep "$GEMCONF" $HOME/.gemrc >>$LOG 2>&1; then
    echo "$GEMCONF" | tee -a $HOME/.gemrc >>$LOG 2>&1 
  fi
  if ! $GEM install passenger >>$LOG 2>&1 ; then
    printf "%25s%15s\n" "'Install Passenger'" "FAIL"
    exit 1
  fi
  printf "%25s%15s\n" "'Install Passenger'" "DONE"

  
fi

echo
echo "Ruby Installation finished."



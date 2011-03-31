#!/bin/bash
#
# Installs Ruby enterprise edition and passenger gem.
# A configuration file is created and included in your '~.bashrc'.
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

echo
echo "Ruby Enterprise edition ('$RUBY_DEST', '$LOG')."

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

echo
echo "Installing:"
if [ ! $RUBY_DONE ]; then
  cd /tmp
  URI="http://rubyenterpriseedition.googlecode.com/files/$RUBY_VER.tar.gz"
  cmd="$WGET $URI" && run_cmd "$cmd" "Download"
  cmd="tar xzf $RUBY_VER.tar.gz" && run_cmd "$cmd" "Unpack"
  cmd="sh /tmp/$RUBY_VER/installer  --dont-install-useful-gems --no-dev-docs --auto=$RUBY_DEST" && run_cmd "$cmd" "Install"
fi

cd "$DIR"

echo 
echo "Preparing:"

if ! [ -f "$RUBY_CONF" ]; then

  echo "if ! [[ \"\$PATH\" =~ \"$RUBY_DEST\" ]]; then export PATH=\"$RUBY_DEST/bin:\$PATH\"; fi" >> "$RUBY_CONF"

  echo "Ruby configuration has been stored in '$RUBY_CONF'."
  if ! grep "$RUBY_CONF" $HOME/.bashrc >/dev/null 2>&1 ; then
    echo "source \"$RUBY_CONF\"" >> $HOME/.bashrc
  fi

else
  echo "It seems RUBY is already configured ('$RUBY_CONF' exists)."
fi
source "$RUBY_CONF"


echo
echo "Passenger:"
GEM="`which gem`"
if [ ! -e "$GEM" ]; then
  echo "'gem' missing. Install 'gem' first. Aborting..."
  exit 1
fi

if [ "$PASSENGER_SKIP" != "s" ]; then
  export PATH="$RUBY_DEST/bin:$PATH"
  cmd="$GEM sources -a http://gemcutter.org" && run_cmd "$cmd" "Add Gemcutter"
  cmd="$GEM sources -a http://rubygems.org" && run_cmd "$cmd" "Add Rubygems"
  GEMCONF="gem: --no-ri --no-rdoc"
  if ! grep "$GEMCONF" $HOME/.gemrc >>$LOG 2>&1; then
    echo "$GEMCONF" | tee -a $HOME/.gemrc >>$LOG 2>&1 
  fi
  cmd="$GEM install passenger" && run_cmd "$cmd" "Install Passenger"
  
fi


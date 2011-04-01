#!/bin/bash
#
# Installs Ruby enterprise edition and passenger gem.
# A configuration file is created and included in your '~.bashrc'.
# Pass a ruby version string as first argument to install a specific version (blank for default).
# Author: Christoph Helma, Andreas Maunz.
#

source "`pwd`/utils.sh"
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
echo "Ruby Enterprise edition ('$RUBY_DEST', '$LOG')."


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
  if ! [ -d "/tmp/$RUBY_VER" ]; then
    cmd="$WGET $URI" && run_cmd "$cmd" "Download"
    cmd="tar xzf $RUBY_VER.tar.gz" && run_cmd "$cmd" "Unpack"
  fi
  cmd="sh /tmp/$RUBY_VER/installer  --dont-install-useful-gems --no-dev-docs --auto=$RUBY_DEST" && run_cmd "$cmd" "Install"
fi



if ! [ -f "$RUBY_CONF" ]; then

  echo "if ! [[ \"\$PATH\" =~ \"$RUBY_DEST\" ]]; then export PATH=\"$RUBY_DEST/bin:\$PATH\"; fi" >> "$RUBY_CONF"

  echo "Ruby configuration has been stored in '$RUBY_CONF'."
  if ! grep "$RUBY_CONF" $HOME/.bashrc >/dev/null 2>&1 ; then
    echo "source \"$RUBY_CONF\"" >> $HOME/.bashrc
  fi
fi
source "$RUBY_CONF"


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
  if ! $GEM list | grep passenger >/dev/null 2>&1; then
    cmd="$GEM install passenger" && run_cmd "$cmd" "Install Passenger"
  fi
  
fi

cd "$DIR"

#!/bin/sh
#
# Installs Ruby enterprise edition and passenger gem.
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
RBENV="`which rbenv`"
if [ ! -e "$RBENV" ]; then
  echo "'rbenv' missing. Install 'rbenv' first. Aborting..."
  exit 1
fi

# Pkg
LOG="$HOME/tmp/`basename $0`-log.txt"

echo
echo "Ruby ('$RUBY_DEST', '$LOG')."


mkdir "$RUBY_DEST" >/dev/null 2>&1
if [ ! -d "$RUBY_DEST" ]; then
  echo "Install directory '$RUBY_DEST' is not available! Aborting..."
  exit 1
else
  if ! rmdir "$RUBY_DEST" >/dev/null 2>&1; then # if not empty this will fail
    RUBY_DONE=true
  fi
fi

if [ ! $RUBY_DONE ]; then
  cd $HOME/tmp
  URI="http://ftp.ruby-lang.org/pub/ruby/1.9/$RUBY_VER.tar.gz"
  if ! [ -d "$RUBY_VER" ]; then
    cmd="$WGET $URI" && run_cmd "$cmd" "Download"
    cmd="tar xzf $RUBY_VER.tar.gz" && run_cmd "$cmd" "Unpack"
  fi
  cmd="cd $RUBY_VER" && run_cmd "$cmd" "cd"
  cmd="./configure --prefix=$RUBY_DEST" && run_cmd "$cmd" "Configure"
  cmd="make" && run_cmd "$cmd" "Make"
  cmd="make install" && run_cmd "$cmd" "Install"
  cmd="cd -" && run_cmd "$cmd" "cd"
fi

cmd="$RBENV rehash" && run_cmd "$cmd" "Rbenv Update"


#GEM="`which gem`"
#if [ ! -e "$GEM" ]; then
#  echo "'gem' missing. Install 'gem' first. Aborting..."
#  exit 1
#fi
#
#export PATH="$RUBY_DEST/bin:$PATH"
#cmd="$GEM sources -a http://gemcutter.org" && run_cmd "$cmd" "Add Gemcutter"
#cmd="$GEM sources -a http://rubygems.org" && run_cmd "$cmd" "Add Rubygems"
#GEMCONF="gem: --no-ri --no-rdoc"
#if ! grep "$GEMCONF" $HOME/.gemrc >>$LOG 2>&1; then
#  echo "$GEMCONF" | tee -a $HOME/.gemrc >>$LOG 2>&1 
#fi


  
cd "$DIR"

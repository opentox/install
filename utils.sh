#!/bin/sh

# Shell library for service installation and general tools
# Author: Christoph Helma, Andreas Maunz

# Functions to install ruby and install services with bundler.
# Ensures presence of ~/.opentox (CONFIG) and OT_PREFIX.

check_dest() 
{
  [ -d "$OT_PREFIX/tmp" ] || mkdir -p "$OT_PREFIX/tmp"
  if ! [ -d "$OT_PREFIX/tmp" ]; then
    echo "Could not create OT_PREFIX directory! Aborting..."
    exit 1
  fi
  [ -d "$HOME/.opentox/log" ] || mkdir -p "$HOME/.opentox/log"
  if ! [ -d "$HOME/.opentox/log" ]; then
    echo "Could not create CONFIG (~/.opentox) directory! Aborting..."
    exit 1
  fi
}

run_cmd ()
{
  local cmd="$1"; local title="$2"
  printf "%50s" "$title"
  if ! eval $cmd >>$LOG 2>&1 ; then  
    printf "                              [ \033[31m%s\033[m ]\n" "FAIL"
    echo "Last 10 lines of log:"
    tail -10 "$LOG"
    exit 1
  fi
  printf "                              [  \033[32m%s\033[m  ]\n" "OK"
}


check_utils() {
  for u in $1; do
    eval `echo $u | tr "[:lower:]" "[:upper:]" | tr "-" "_"`=`which $u` || (echo "'$u' missing. Install '$u' first." 1>&2 && exit 1)
  done
}


install_ruby() {
  printf "\n%50s\n" "RUBY"
  local DIR=`pwd`
  check_utils "rbenv curl make"
  if ! $RBENV versions $RUBY_NUM_VER | grep $RUBY_NUM_VER>/dev/null 2>&1; then
    [ -d $DIR/tmp ] || mkdir -p $DIR/tmp && cd $DIR/tmp
    ([ -d $DIR/tmp/ruby-$RUBY_NUM_VER ] || $CURL $RUBY_DWL/ruby-$RUBY_NUM_VER.tar.gz 2>/dev/null | tar xz) && cd ruby-$RUBY_NUM_VER
    cmd="./configure --prefix=$RUBY_DIR" && run_cmd "$cmd" "Configure"
    cmd="$MAKE -j2" && run_cmd "$cmd" "Make"
    cmd="$MAKE install" && run_cmd "$cmd" "Install"
  fi
  cd $DIR
  cmd="$RBENV rehash" && run_cmd "$cmd" "Rbenv rehash"
  cmd="$RBENV local $RUBY_NUM_VER" && run_cmd "$cmd" "Rbenv set ruby"
}


install_with_bundler() {
  printf "\n%50s\n" "INSTALL"
  check_utils "gem rbenv"
  $GEM list | grep bundler >/dev/null 2>&1 || (cmd="$GEM install bundler" && run_cmd "$cmd" "Install bundler")
  cmd="$RBENV rehash" && run_cmd "$cmd" "Rbenv rehash"
  cmd="bundle install" && run_cmd "$cmd" "Install using bundler"
}


if [ -z "$OT_PREFIX" ]; then
  . ./config.sh
else
  . $HOME/.opentox/config/install/config.sh
fi
check_dest
touch "$OT_UI_CONF"
. "$OT_UI_CONF" 2>/dev/null


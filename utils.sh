#!/bin/sh

# Shell library for service installation and general tools
# Author: Christoph Helma, Andreas Maunz

# Functions to install ruby and install services with bundler.
# Ensures presence of ~/.opentox (CONFIG) and OT_PREFIX.

# create a temporary directory in OT_PREFIX and a log directory in .opentox
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

# export a LOG file name
check_log()
{
  local name="$1"
  if [ -z "$LOG" ]; then
    LOG="$OT_PREFIX/tmp/$name.log"
    echo
    printf "\033[1m%s\033[m\n" "$name ('$LOG'):"
    echo
  fi
}

# run a shell command
# Signal exit status by formatted string
# @param cmd command to execute 
# @param title textual description of command
# @example {
#   run_cmd "ls" "list dir"
# }
run_cmd ()
{
  local cmd="$1"; local title="$2"
  printf "%50s" "$title"
  if ! eval "$cmd" >>$LOG 2>&1 ; then  
    printf "                              [ \033[31m%s\033[m ]\n" "FAIL"
    echo "Last 10 lines of log:"
    tail -10 "$LOG"
    exit 1
  fi
  printf "                              [  \033[32m%s\033[m  ]\n" "OK"
}


# stop if required binaries not in path
# @param list of binaries
# @example {
#   check_utils "git curl"
# }
check_utils() {
  for u in $1; do
    eval `echo $u | tr "[:lower:]" "[:upper:]" | tr "-" "_"`=`which $u` || (echo "'$u' missing. Install '$u' first." 1>&2 && exit 1)
  done
}


# install ruby using rbenv
# configure the version in config.sh
install_ruby() {
  printf "\n%50s\n" "RUBY"
  local DIR=`pwd`
  check_utils "rbenv curl make tar"
  if ! $RBENV versions $RUBY_NUM_VER | grep $RUBY_NUM_VER>/dev/null 2>&1; then
    [ -d $OT_PREFIX/tmp ] || mkdir -p $OT_PREFIX/tmp && cd $OT_PREFIX/tmp
    ([ -d $OT_PREFIX/tmp/ruby-$RUBY_NUM_VER ] || $CURL $RUBY_DWL/ruby-$RUBY_NUM_VER.tar.gz 2>/dev/null | $TAR xz) && cd ruby-$RUBY_NUM_VER
    cmd="./configure --prefix=$RUBY_DIR" && run_cmd "$cmd" "Configure"
    cmd="$MAKE -j2" && run_cmd "$cmd" "Make"
    cmd="$MAKE install" && run_cmd "$cmd" "Install"
  fi
  cd $DIR
  cmd="$RBENV rehash" && run_cmd "$cmd" "Rbenv rehash"
  cmd="$RBENV local $RUBY_NUM_VER" && run_cmd "$cmd" "Rbenv set ruby"
}

# install a ruby gem using bundler
install_with_bundler() {
  printf "\n%50s\n" "INSTALL"
  check_utils "gem rbenv bundle"
  $GEM list | grep bundler >/dev/null 2>&1 || (cmd="$GEM install bundler" && run_cmd "$cmd" "Install bundler")
  cmd="$RBENV rehash" && run_cmd "$cmd" "Rbenv rehash"
  cmd="$BUNDLE install" && run_cmd "$cmd" "Install using bundler"
}

# download opentox git repo
ot_git_download(){
  printf "\n%50s\n" "GIT DOWNLOAD"
  check_utils "git"
  cd $OT_PREFIX
  cmd="$GIT clone git@github.com:opentox/$SERVICE.git" && run_cmd "$cmd" "Downloading $SERVICE git repository"
}

# install opentox service
install_ot_service(){
  printf "\n%50s\n" "$SERVICE"
  check_utils "git rbenv"
  local DIR=`pwd`
  cd $OT_PREFIX
  ot_git_download
  cd $SERVICE
  $GIT checkout $OT_BRANCH  >>$LOG 2>&1
  $RBENV local $RUBY_NUM_VER 
  case "$SERVICE" in
    opentox-*) install_with_bundler;;
    feature) install_with_bundler;;
    task) install_with_bundler;;
    *) cd bin; for f in `ls`; do ./$f; done;; 
  esac
  cd $DIR
}

# emit notification if caller was the shell (the user), see http://goo.gl/grCOk
notify() {
  echo
  echo "Installation succesful"
  echo
  if ps -o stat= -p $PPID | grep "s" >/dev/null 2>&1; then
    echo "IMPORTANT: How to configure your system:"
    echo "IMPORTANT: a) Include '$OT_TOOLS_CONF' in shell startup (e.g. ~/.bashrc)."
    echo "IMPORTANT: b) Manually source '$OT_TOOLS_CONF' every time."
    echo "IMPORTANT: The command in both cases: '. $OT_TOOLS_CONF'"
    echo "IMPORTANT: NOW would be the best time to configure!"
    echo "Visit 'http://opentox.github.com/General/2012/08/09/install-opentox-development-environment/' for further information about the usage of ot-tools."
    echo
    echo "Thank you for your attention."
    echo
  fi
}


# Force loading configuration from local, if we are installing for the first time
if [ -z "$OT_PREFIX" ]; then
  . ./config.sh
else
  . $HOME/.opentox/config/install/config.sh
fi
check_dest
touch "$OT_UI_CONF"
. "$OT_UI_CONF" 2>/dev/null


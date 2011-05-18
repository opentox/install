#!/bin/sh
#
# Installs Opentox-ruby gem.
# Author: Christoph Helma, Andreas Maunz.
#

. "`pwd`/utils.sh"
DIR="`pwd`"

if [ "$(id -u)" = "0" ]; then
  echo "This script must be run as non-root." 1>&2
  exit 1
fi

# Utils
GIT="`which git`"
if [ ! -e "$GIT" ]; then
  echo "'git' missing. Install 'git' first. Aborting..."
  exit 1
fi

GEM="`which gem`"
if [ ! -e "$GEM" ]; then
  echo "'gem' missing. Install 'gem' first. Aborting..."
  exit 1
fi

RAKE="`which rake`"
if [ ! -e "$RAKE" ]; then
  echo "'rake' missing. Install 'rake' first. Aborting..."
  exit 1
fi


# Pkg
LOG="/tmp/`basename $0`-log.txt"

echo
echo "Opentox-ruby ('$LOG'):"

for mygem in opentox-ruby builder jeweler; do
  if ! $GEM list | grep "$mygem" >/dev/null 2>&1; then
    cmd="$GEM install $mygem" && run_cmd "$cmd" "$mygem"
  fi
done


servername="`hostname`"
serverdomain="`dnsdomainname`"
if [ -n "$serverdomain" ]; then
  servername="$servername"."$serverdomain"
fi
escapedserver="`echo $servername | sed 's/\/\\\//'`"

if [ "$OT_BRANCH" = "development" ]; then
  logger=":logger: backtrace"
else
  logger=""
fi

if [ "$OT_INSTALL" = "server" ]; then
  aa="https:\/\/opensso.in-silico.ch"
else
  aa=""
fi

mkdir -p "$HOME/.opentox/config" >>$LOG 2>&1
mkdir -p "$HOME/.opentox/log" >>$LOG 2>&1

$GIT checkout production.yaml      >>$LOG 2>&1
$GIT checkout aa-$OT_INSTALL.yaml  >>$LOG 2>&1

cmd="sed -e \"s,SERVERNAME,$servername,;s,ESCAPEDSERVER,$escapedserver,;s,LOGGER,$logger,;s,AA,$aa,;s,WWW_DEST,$WWW_DEST,\" production.yaml > $HOME/.opentox/config/production.yaml" && run_cmd "$cmd" "Config 1"
cmd="sed -e \"s,SERVERNAME,$servername,;s,ESCAPEDSERVER,$escapedserver,;s,LOGGER,$logger,;s,AA,$aa,;s,WWW_DEST,$WWW_DEST,\" aa-$OT_INSTALL.yaml >> $HOME/.opentox/config/production.yaml" && run_cmd "$cmd" "Config 1"

if [ "$OT_BRANCH" = "development" ] || expr match "$OT_BRANCH" "release"; then
  mkdir -p $WWW_DEST/opentox >>$LOG 2>&1
  cd $WWW_DEST/opentox >>$LOG 2>&1
  rm -rf opentox-ruby >>$LOG 2>&1
  $GIT clone git://github.com/opentox/opentox-ruby.git >>$LOG 2>&1
  cd opentox-ruby >>$LOG 2>&1
  $GIT checkout -b $OT_BRANCH origin/$OT_BRANCH >>$LOG 2>&1
  cmd="$RAKE install" && run_cmd "$cmd" "Install"
  GEM_LIB=`$GEM which opentox-ruby | sed 's/\/opentox-ruby.rb//'`
  rm -rf "$GEM_LIB~" >>$LOG 2>&1
  mv "$GEM_LIB" "$GEM_LIB~" >>$LOG 2>&1
  cmd="ln -sf $WWW_DEST/opentox/opentox-ruby/lib $GEM_LIB" && run_cmd "$cmd" "Linking back"
fi

cd "$DIR"

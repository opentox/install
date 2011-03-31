#!/bin/bash
#
# Installs Opentox-ruby gem.
# Author: Christoph Helma, Andreas Maunz.
#

source ./config.sh
source ./utils.sh

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

echo "Opentox-ruby ('$LOG'):"
DIR="`pwd`"

for mygem in opentox-ruby builder jeweler; do
  cmd="$GEM install $mygem" && run_cmd "$cmd" "$mygem"
done


servername="`hostname`"
escapedserver="`echo $servername | sed 's/\/\\\//'`"
logger=":logger: backtrace"
aa="nil"

mkdir -p "$HOME/.opentox/config" >>$LOG 2>&1
mkdir -p "$HOME/.opentox/log" >>$LOG 2>&1
sed -e "s/SERVERNAME/$servername/;s/ESCAPEDSERVER/$escapedserver/;s/LOGGER/$logger/;s/AA/$aa/" production.yaml > $HOME/.opentox/config/production.yaml 2>$LOG
sed -e "s/SERVERNAME/$servername/;s/ESCAPEDSERVER/$escapedserver/;s/LOGGER/$logger/;s/AA/$aa/" aa-local.yaml >> $HOME/.opentox/config/production.yaml 2>$LOG

mkdir -p $WWW_DEST/opentox >>$LOG 2>&1
cd $WWW_DEST/opentox >>$LOG 2>&1
$GIT clone git://github.com/opentox/opentox-ruby.git >>$LOG 2>&1
cd opentox-ruby >>$LOG 2>&1
$GIT checkout -b development origin/development>>$LOG 2>&1

cmd="$RAKE install" && run_cmd "$cmd" "Install"

GEM_LIB=`$GEM which opentox-ruby | sed 's/\/opentox-ruby.rb//'`
mv "$GEM_LIB" "$GEM_LIB~" >>$LOG 2>&1

cmd="ln -sf $WWW_DEST/opentox/opentox-ruby/lib $GEM_LIB" && run_cmd "$cmd" "Linking back"

cd "$DIR"


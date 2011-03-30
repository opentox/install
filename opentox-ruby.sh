#!/bin/bash
#
# Installs Opentox-ruby gem.
# Author: Christoph Helma, Andreas Maunz.
#

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
source ./config.sh


echo "This installs the Opentox-ruby gem."
echo "Press <Return> to continue, or <Ctrl+C> to abort."
read

DIR="`pwd`"

$GEM install opentox-ruby
$GEM install builder # not included by spreadsheet gem

SERVERNAME="`hostname`"
ESCAPED_SERVERNAME="`echo $SERVERNAME | sed 's/\/\\\//'`"
LOGGER=":logger: backtrace"
AA="nil"

mkdir -p "$HOME/.opentox/config"
mkdir -p "$HOME/.opentox/log"
sed -e "s/SERVERNAME/$servername/;s/ESCAPEDSERVERNAME/$escapedservername/;s/LOGGER/$logger/;s/AA/$aa/" production.yaml > $HOME/.opentox/config/production.yaml
sed -e "s/SERVERNAME/$servername/;s/ESCAPEDSERVERNAME/$escapedservername/;s/LOGGER/$logger/;s/AA/$aa/" "aa-local.yaml" >> $HOME/.opentox/config/production.yaml

mkdir -p $WWW_DEST/opentox
cd $WWW_DEST/opentox
$GIT clone "git://github.com/opentox/opentox-ruby.git "
cd opentox-ruby
pwd
$GIT remote show origin
$GIT fetch
$GIT checkout -b development origin/development
$GEM install jeweler
$RAKE install
GEM_LIB=`$GEM which opentox-ruby | sed 's/\/opentox-ruby.rb//'`
echo "'$GEM_LIB'"
mv "$GEM_LIB" "$GEM_LIB~"
ln -s "$WWW_DEST/opentox/opentox-ruby/lib" "$GEM_LIB"

cd "$DIR"

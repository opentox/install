#!/bin/sh
#
# Installs Kernlab.
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

R="`which R`"
if [ ! -e "$R" ]; then
  echo "'R' missing. Install 'R' first. Aborting..."
  exit 1
fi

# Pkg
LOG="$HOME/tmp/`basename $0`-log.txt"

echo
echo "Kernlab ('$LOG')."

R_DONE=false
mkdir "$R_DEST" >/dev/null 2>&1
if [ ! -d "$R_DEST" ]; then
  echo "Install directory '$R_DEST' is not available! Aborting..."
  exit 1
else
  if ! rmdir "$R_DEST" >/dev/null 2>&1; then # if not empty this will fail
    R_DONE=true
  else
    mkdir "$R_DEST" >/dev/null 2>&1
  fi
fi


if ! $R_DONE; then
  export R_LIBS="$R_DEST" # To install non-global
  cmd="$R CMD BATCH packs.R" && run_cmd "$cmd" "R packages"
  eval "$cmd"
fi


if [ ! -f $R_CONF ]; then

  echo "if echo \"\$R_LIBS\" | grep -v \"$R_DEST\">/dev/null 2>&1; then export R_LIBS=\"$R_DEST\"; fi" >> "$R_CONF"
  echo "if ! [ -d \"$R_DEST\" ]; then echo \"\$0: '$R_DEST' is not a directory!\"; fi" >> "$R_CONF"
  echo "R package destination has been stored in '$R_CONF'."

  if ! grep "$R_CONF" $OT_UI_CONF >/dev/null 2>&1 ; then
    echo ". \"$R_CONF\"" >> $OT_UI_CONF
  fi

fi

cd "$DIR"


#!/bin/bash
#
# Installs Kernlab.
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

R="`which R`"
if [ ! -e "$R" ]; then
  echo "'R' missing. Install 'R' first. Aborting..."
  exit 1
fi

# Pkg
LOG="/tmp/`basename $0`-log.txt"

echo "Kernlab ('$LOG')."

R_DONE=false
mkdir "$KL_DEST" >/dev/null 2>&1
if [ ! -d "$KL_DEST" ]; then
  echo "Install directory '$KL_DEST' is not available! Aborting..."
  exit 1
else
  if ! rmdir "$KL_DEST" >/dev/null 2>&1; then # if not empty this will fail
    echo "Install directory '$KL_DEST' not empty. Skipping kernlab installation."
    R_DONE=true
  else
    mkdir "$KL_DEST" >/dev/null 2>&1
  fi
fi


if ! $R_DONE; then
  cd /tmp
  URI="http://cran.r-project.org/src/contrib/Archive/kernlab/kernlab_$KL_VER.tar.gz"
  cmd="$WGET $URI" && run_cmd "$cmd" "Download"

  export R_LIBS="$KL_DEST" # To install non-global
  cmd="$R CMD INSTALL kernlab_$KL_VER.tar.gz" && run_cmd "$cmd" "Install"
fi


if [ ! -f $KL_CONF ]; then

  echo "if ! [[ \"\$R_LIBS\" =~ \"$KL_DEST\" ]]; then export R_LIBS=\"$KL_DEST\"; fi" >> "$KL_CONF"
  echo "R package destination has been stored in '$KL_CONF'."

  if ! grep "$KL_CONF" $HOME/.bashrc >/dev/null 2>&1 ; then
    echo "source \"$KL_CONF\"" >> $HOME/.bashrc
  fi

fi

cd "$DIR"


#!/bin/bash
#
# Installs Kernlab.
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

R="`which R`"
if [ ! -e "$R" ]; then
  echo "'R' missing. Install 'R' first. Aborting..."
  exit 1
fi

# Pkg
source ./config.sh
if [ -n "$1" ]; then
  KL_DEST="$1"
fi


echo "This installs Kernlab."
echo "Press <Return> to continue, or <Ctrl+C> to abort."
read

DIR="`pwd`"

R_DONE=false
mkdir "$KL_DEST" >/dev/null 2>&1
if [ ! -d "$KL_DEST" ]; then
  echo "Install directory '$KL_DEST' is not available! Aborting..."
  exit 1
else
  if ! rmdir "$KL_DEST" >/dev/null 2>&1; then # if not empty this will fail
    echo "Install directory '$KL_DEST' is not empty. Skipping kernlab installation..."
    R_DONE=true
  else
    mkdir "$KL_DEST" >/dev/null 2>&1
  fi
fi
if ! $R_DONE; then
  cd /tmp
  if ! $WGET -O - "http://cran.r-project.org/src/contrib/Archive/kernlab/kernlab_$KL_VER.tar.gz">/dev/null 2>&1; then
    echo "Download failed! Aborting..."
    exit 1
  fi
  export R_LIBS="$KL_DEST"
  $R CMD INSTALL "kernlab_$KL_VER.tar.gz"
fi

echo 
echo "Preparing R..."
if [ ! -f $KL_CONF ]; then
  echo "export R_LIBS=\"$KL_DEST\"" >> "$KL_CONF"
  echo "R package destination has been stored in '$KL_CONF'."
  echo -n "Decide if R configuration should be linked to your .bashrc ('y/n'): "
  read ANSWER_KL_CONF
  if [ $ANSWER_KL_CONF = "y" ]; then
    echo "source \"$KL_CONF\"" >> $HOME/.bashrc
  fi
else
  echo "It seems R is already configured ('$KL_CONF' exists)."
fi

cd "$DIR"

echo
echo "Kernlab Installation finished."

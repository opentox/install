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
VER="0.9-11"

# Dest
R_CONF=$HOME/.bash_R_ot
DEST="$HOME/r-packages"
if [ -n "$1" ]; then
  DEST="$1"
fi


echo "This installs Kernlab."
echo "Press <Return> to continue, or <Ctrl+C> to abort."
read

DIR="`pwd`"

R_DONE=false
mkdir "$DEST" >/dev/null 2>&1
if [ ! -d "$DEST" ]; then
  echo "Install directory '$DEST' is not available! Aborting..."
  exit 1
else
  if ! rmdir "$DEST" >/dev/null 2>&1; then # if not empty this will fail
    echo "Install directory '$DEST' is not empty. Skipping kernlab installation..."
    R_DONE=true
  fi
fi
if ! $R_DONE; then
cd /tmp
  if ! $WGET -O - "http://cran.r-project.org/src/contrib/Archive/kernlab/kernlab_$VER.tar.gz">/dev/null 2>&1; then
    echo "Download failed! Aborting..."
    exit 1
  fi
  export R_LIBS="$DEST"
  $R CMD INSTALL "kernlab_$VER.tar.gz"
fi

echo 
echo "Preparing R..."
if [ ! -f $R_CONF ]; then
  echo "R_LIBS=\"$DEST\"" >> "$R_CONF"
  echo "R package destination has been stored in '$R_CONF'."
  echo -n "Decide if R configuration should be linked to your .bashrc ('y/n'): "
  read ANSWER_R_CONF
  if [ $ANSWER_R_CONF = "y" ]; then
    echo "source \"$R_CONF\"" >> $HOME/.bashrc
  fi
else
  echo "It seems R is already configured ('$R_CONF' exists)."
fi

cd "$DIR"

echo
echo "Kernlab Installation finished."

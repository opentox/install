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
source ./utils.sh
LOG="/tmp`basename $0`-log.txt"

echo "This installs Kernlab."
echo "Log file is '$LOG'."
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
  URI="http://cran.r-project.org/src/contrib/Archive/kernlab/kernlab_$KL_VER.tar.gz"
  if ! $WGET -O - "$URI">>$LOG 2>&1; then
    printf "%25s%15s\n" "'Download'" "FAIL"
    exit 1
  fi
  printf "%25s%15s\n" "'Download'" "DONE"

  export R_LIBS="$KL_DEST" # To install non-global

  if ! $R CMD INSTALL "kernlab_$KL_VER.tar.gz">>$LOG 2>&1; then
    printf "%25s%15s\n" "'Install'" "FAIL"
  fi
  printf "%25s%15s\n" "'Install'" "DONE"
fi


echo 
echo "Preparing R..."

if [ ! -f $KL_CONF ]; then

  echo "if ! [[ \"\$R_LIBS\" =~ \"$KL_DEST\" ]]; then export R_LIBS=\"$KL_DEST\"; fi" >> "$KL_CONF"
  echo "R package destination has been stored in '$KL_CONF'."

  if ! grep "$KL_CONF" $HOME/.bashrc >/dev/null 2>&1 ; then
    echo "source \"$KL_CONF\"" >> $HOME/.bashrc
  fi

else
  echo "It seems R is already configured ('$KL_CONF' exists)."
fi
source "$KL_CONF"

cd "$DIR"

echo
echo "Kernlab Installation finished."

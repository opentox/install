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
R="`which R`"
if [ ! -e "$R" ]; then
  echo "'R' missing. Install 'R' first. Aborting..."
  exit 1
fi

# Pkg
VER="0.9-11"

DIR="`pwd`"
echo "This installs Kernlab."
echo "Press <Return> to continue, or <Ctrl+C> to abort."
read
cd /tmp
if ! $WGET -O - "http://cran.r-project.org/src/contrib/Archive/kernlab/kernlab_$VER.tar.gz">/dev/null 2>&1; then
  echo "Download failed! Aborting..."
  exit 1
fi
R CMD INSTALL kernlab_$VER.tar.gz
cd "$DIR"

echo
echo "Kernlab Installation finished."

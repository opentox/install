#!/bin/sh

echo "Installing kernlab"
. /etc/profile
cd /tmp
wget http://cran.r-project.org/src/contrib/Archive/kernlab/kernlab_0.9-11.tar.gz
R CMD INSTALL kernlab_0.9-11.tar.gz
cd -

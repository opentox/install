#!/bin/bash

source config.sh
source utils.sh
LOG="$OT_PREFIX/tmp/service_install.log"
DIR=`pwd`
for SERVICE in opentox-client opentox-server dataset algorithm; do
  install_ot_service
done
cd $DIR

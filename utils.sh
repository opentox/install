#!/bin/bash

function check_dest {
  if ! [ -d $PREFIX ]; then
    if ! mkdir -p $PREFIX;
      echo "Could not create target directory '$PREFIX'! Aborting..."
      exit 1
    fi
  fi
}

check_dest

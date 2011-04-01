#!/bin/bash

check_dest() 
{
  if ! [ -d "$PREFIX" ]; then
    if ! mkdir -p "$PREFIX"; then
      echo "Could not create target directory '$PREFIX'! Aborting..."
      exit 1
    fi
  fi
}

run_cmd ()
{
  local cmd="$1"
  local title="$2"

  if ! eval $cmd >>$LOG 2>&1 ; then
    printf "%25s%15s\n" "'$title'" "FAIL"
    exit 1
  fi
  printf "%25s%15s\n" "'$title'" "DONE"

}

abs_path()
{
  local path="$1"
  case "$path" in
     /*) absolute=1 ;;
      *) absolute=0 ;;
  esac
}

source ~/.bashrc
source .config.sh
check_dest

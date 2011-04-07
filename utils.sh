#!/bin/sh

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

  printf "%15s" "'$title'"
  if ! eval $cmd >>$LOG 2>&1 ; then  
    printf "%25s\n" "FAIL"
    exit 1
  fi
  printf "%25s\n" "DONE"

}

abs_path()
{
  local path="$1"
  case "$path" in
     /*) absolute=1 ;;
      *) absolute=0 ;;
  esac
}

. "`pwd`/config.sh"
. "$OT_UI_CONF"
check_dest

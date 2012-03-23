#!/bin/sh

check_dest() 
{
  [ -d "$OT_PREFIX/tmp" ] || mkdir -p "$OT_PREFIX/tmp"
  if ! [ -d "$OT_PREFIX/tmp" ]; then
    echo "Could not create target directory! Aborting..."
    exit 1
  fi
}

run_cmd ()
{
  local cmd="$1"
  local title="$2"

  printf "%30s" "'$title'"
  if ! eval $cmd >>$LOG 2>&1 ; then  
    printf "%50s\n" "FAIL"
    echo "Last 10 lines of log:"
    tail -10 "$LOG"
    exit 1
  fi
  printf "%50s\n" "DONE"

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
touch "$OT_UI_CONF"
. "$OT_UI_CONF" 2>/dev/null
check_dest

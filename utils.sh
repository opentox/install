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
  local len=`echo "$title" | wc -c`
  len=$((40-$len))

  echo -n "$title"
  if ! eval $cmd >>$LOG 2>&1 ; then  
    printf "%$(len)s\n" "'$title'" "FAIL"
    exit 1
  fi
  printf "%$(len)s\n" "'$title'" "DONE"

}

abs_path()
{
  local path="$1"
  case "$path" in
     /*) absolute=1 ;;
      *) absolute=0 ;;
  esac
}

. "$HOME/.bashrc"
. "`pwd`/config.sh"
check_dest

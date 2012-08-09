# Some useful scripts to put in your ~/.bashrc in case you are using bash (assuming OT_PREFIX is '~/opentox-ruby')

# Load server config
otconfig() {
  source $HOME/.opentox/opentox-ui.sh
}

# Update the version
#otupdate() {
#  START_DIR=`pwd`
#  otconfig
#  cd $HOME/opentox-ruby/www/opentox
#  for d in `find -not -name "." -type d -maxdepth 1 2>/dev/null`; do echo ; echo $d ; cd $d ; MYBRANCH=`git branch | grep "*" | sed 's/.*\ //g'`; git pull origin $MYBRANCH ; cd - ;  done
#  cd  $HOME/opentox-ruby/www/opentox/algorithm/libfminer
#  mv libbbrc/Makefile libbbrc/Makefile~
#  mv liblast/Makefile liblast/Makefile~
#  if ! git pull; then
#    echo "Error! Pull for Fminer failed."
#    return 1
#  fi
#  mv libbbrc/Makefile~ libbbrc/Makefile
#  mv liblast/Makefile~ liblast/Makefile
#  make -C libbbrc/ clean
#  make -C libbbrc/ ruby
#  make -C liblast/ clean
#  make -C liblast/ ruby
#  cd -
#  cd $HOME/opentox-ruby/www/opentox/algorithm/last-utils
#  if ! git pull; then
#    echo "Error! Pull for Last-Utils failed."
#    return 1
#  fi
#  cd -
#  cd $HOME/opentox-ruby/www/opentox/algorithm/bbrc-sample
#  if ! git pull; then
#    echo "Error! Pull for Bbrc-Sample failed."
#    return 1
#  fi
#  cd -
#  cd opentox-ruby
#  LINK_DIR=`gem which opentox-ruby | sed 's/\/opentox-ruby.rb//'`
#  if [ -h $LINK_DIR ]; then 
#    rm -f $LINK_DIR
#  fi
#  rake install
#  if ! [ -h $LINK_DIR ]; then
#    echo "Warning! Your lib $LINK_DIR is no symlink. Linking back for you..."
#    rm -rf "$LINK_DIR~"
#    mv "$LINK_DIR" "$LINK_DIR~"
#    ln -sf $HOME/opentox-ruby/www/opentox/opentox-ruby/lib `echo ${LINK_DIR::${#LINK_DIR}-3}`
#  fi
#  echo "Please execute 'otstart' to restart."
#  cd "$START_DIR"
#}

# Start the server
otstart() {
  if [ $# != 1 ]
  then
    echo "One argument required: [service_name] or 'all'"
    echo "usage: $0 [all|algorithm|compound|dataset|feature|model|task|validation|4store]"
    return 1
  fi 

  otconfig
  otkill $1
  DIR=`pwd`
  case "$1" in
    "algorithm") 
      cd $HOME/opentox-ruby/$1;
      nice bash -c "nohup unicorn -p 8081 >/dev/null 2>&1 &"; 
      ;;
    "compound") 
      echo "$1 not available yet."
      #cd $HOME/opentox-ruby/$1;
      #nice bash -c "nohup unicorn -p 8082 >/dev/null 2>&1 &"; 
      ;;
    "dataset")
      cd $HOME/opentox-ruby/$1;
      nice bash -c "nohup unicorn -p 8083 >/dev/null 2>&1 &"; 
      ;;
    "feature")
      cd $HOME/opentox-ruby/$1;
      nice bash -c "nohup unicorn -p 8084 >/dev/null 2>&1 &"; 
      ;;
    "model") 
      echo "$1 not available yet."
      #cd $HOME/opentox-ruby/$1;
      #nice bash -c "nohup unicorn -p 8085 >/dev/null 2>&1 &"; 
      ;;
    "task")
      cd $HOME/opentox-ruby/$1;
      nice bash -c "nohup unicorn -p 8086 >/dev/null 2>&1 &"; 
      ;;
    "validation") 
      echo "$1 not available yet."
      #cd $HOME/opentox-ruby/$1;
      #nice bash -c "nohup unicorn -p 8087 >/dev/null 2>&1 &"; 
      ;;
    "4store") 
      nice bash -c "nohup $HOME/opentox-ruby/4S/bin/4s-backend opentox >/dev/null 2>&1 &"; 
      sleep 1; 
      nice bash -c "nohup $HOME/opentox-ruby/4S/bin/4s-httpd -D -H localhost -p 8088 opentox >/dev/null 2>&1 &"; 
      sleep 1; 
      if ! pgrep -u $USER 4s-backend>/dev/null 2>&1; then echo "Failed to start 4s-backend."; fi
      if ! pgrep -u $USER 4s-httpd>/dev/null 2>&1; then echo "Failed to start 4s-httpd."; fi     
      ;;
    "all")
      otstart 4store;
      otstart algorithm;
      otstart dataset;
      otstart feature;
      otstart task;
      ;;
  esac
  cd $DIR
}

# Display log
alias otless='less $HOME/.opentox/log/development.log'

# Tail log
alias ottail='tail -f $HOME/.opentox/log/development.log'

# Reload the server
#otreload() {
  #otconfig
  #bash -c "nginx -s reload"
#}

# Kill the server
otkill() {
  if [ $# != 1 ]
  then
    echo "One argument required: [service_name] or 'all'"
    echo "usage: $0 [all|algorithm|compound|dataset|feature|model|task|validation|4store]"
    return 1
  fi 

  otconfig
  case "$1" in
    "algorithm") 
      for p in `ps x | grep 'unicorn' | grep 8081 | grep -v grep | awk '{print $1}'`; do kill -9 $p; done;
      ;;
    "compound") 
      #for p in `ps x | grep 'unicorn' | grep 8082 | grep -v grep | awk '{print $1}'`; do kill -9 $p; done;
      ;;
    "dataset")
      for p in `ps x | grep 'unicorn' | grep 8083 | grep -v grep | awk '{print $1}'`; do kill -9 $p; done;
      ;;
    "feature")
      for p in `ps x | grep 'unicorn' | grep 8084 | grep -v grep | awk '{print $1}'`; do kill -9 $p; done;
      ;;
    "model") 
      #for p in `ps x | grep 'unicorn' | grep 8085 | grep -v grep | awk '{print $1}'`; do kill -9 $p; done;
      ;;
    "task")
      for p in `ps x | grep 'unicorn' | grep 8086 | grep -v grep | awk '{print $1}'`; do kill -9 $p; done;
      ;;
    "validation") 
      echo "$1 not available yet."
      #for p in `ps x | grep 'unicorn' | grep 8087 | grep -v grep | awk '{print $1}'`; do kill -9 $p; done;
      ;;
    "4store") 
      killall 4s-httpd >/dev/null 2>&1;
      killall 4s-backend >/dev/null 2>&1;
      ;;
    "all")
      otkill algorithm;
      #otkill compound;
      otkill dataset;
      otkill feature;
      #otkill model;
      otkill task;
      #otkill validation;
      otkill 4store;
      ;;
  esac
}

# Check the server
#otcheck() {
#  check_service=`cat $HOME/.opentox/config/production.yaml  | grep opentox-algorithm | sed 's/.*\s//g' | sed 's/"//g'`
#  if [ -z "`curl -v $check_service 2>&1 | grep '200 OK'`" ]; then
#    otstart
#  fi
#}


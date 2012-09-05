# Some useful scripts to put in your ~/.bashrc in case you are using bash (assuming OT_PREFIX is '~/opentox-ruby')

# Load server config
otconfig() {
  . $HOME/.opentox/config/install/config.sh
  . $OT_PREFIX/install/utils.sh
}

# Display log
alias otless='less $HOME/.opentox/log/development.log'

# Tail log
alias ottail='tail -f $HOME/.opentox/log/development.log'

# Start unicorn
# @param1 [service_name] 
# @param2 integer Port
# @example start_unicorn algorithm 8081
start_unicorn() {
  cd $HOME/opentox-ruby/$1
  nice bash -c "nohup unicorn -p $2 >/dev/null 2>&1 &"
}

# Start unicorn
# @param1 [backend_name] 
# @param2 integer Port
# @example start_unicorn algorithm 8081
start_4s() {
  nice bash -c "nohup $OT_PREFIX/4S/bin/4s-backend $1 >/dev/null 2>&1 &";
  sleep 0.5;
  nice bash -c "nohup $OT_PREFIX/4S/bin/4s-httpd -H localhost -p $2 -s -1 $1 >/dev/null 2>&1 &"; #-D for testing        
  sleep 0.5;

}

# Start the server
otstart() {
  if [ $# != 1 ]
  then
    echo "One argument required: [service_name] or 'all'"
    echo "usage: otstart [all|algorithm|compound|dataset|feature|model|task|validation|4store]"
    return 1
  fi 

  otconfig
  otkill $1
  DIR=`pwd`
  case "$1" in
    "algorithm")  start_unicorn $1 8081;;
    "compound")   start_unicorn $1 8082;;
    "dataset")    start_unicorn $1 8083;;
    "feature")    start_unicorn $1 8084;;
    "model")      start_unicorn $1 8085;;
    "task")       start_unicorn $1 8086;;
    "validation") #start_unicorn $1 8087;;
                  echo "$1 not available yet.";;
    "4store")     start_4s opentox 9088; 
                  if ! pgrep -u $USER 4s-backend>/dev/null 2>&1; then echo "Failed to start 4s-backend."; fi
                  if ! pgrep -u $USER 4s-httpd>/dev/null 2>&1; then echo "Failed to start 4s-httpd."; fi;;
    "all")        otstart 4store;
                  otstart algorithm;
                  otstart compound;
                  otstart dataset;
                  otstart feature;
                  otstart model;
                  otstart task;;
                  #otstart validation;;
    *)            echo "One argument required: [service_name] or 'all'";
                  echo "usage: otstart [all|algorithm|compound|dataset|feature|model|task|validation|4store]";
                  return 1;;
  esac
  cd $DIR
}

# reload unicorn
# @param1 integer Port
# @example reload_unicorn 8081
reload_unicorn() {
  for p in `ps x | grep 'unicorn master' | grep $1 | grep -v grep | awk '{print $1}'`; do 
    kill -12 $p 
  done
  sleep 0.5
  for p in `ps x | grep 'unicorn master (old)' | grep $1 | grep -v grep | awk '{print $1}'`; do 
    kill -28 $p
  done
  sleep 0.5
  # ToDo: Check if new master is working properly.
  for p in `ps x | grep 'unicorn master (old)' | grep $1 | grep -v grep | awk '{print $1}'`; do
    kill -3 $p
  done
}

# Reload the server
otreload() {
  if [ $# != 1 ]
  then
    echo "One argument required: [service_name] or 'all'"
    echo "usage: otreload [all|algorithm|compound|dataset|feature|model|task|validation|4store]"
    return 1
  fi 

  otconfig
  case "$1" in
    "algorithm")  reload_unicorn 8081;;
    "compound")   reload_unicorn 8082;;
    "dataset")    reload_unicorn 8083;;
    "feature")    reload_unicorn 8084;;
    "model")      reload_unicorn 8085;;
    "task")       reload_unicorn 8086;;
    "validation") #reload_unicorn 8087;;
                  echo "$1 not available yet.";;
    "4store")     #killall 4s-httpd >/dev/null 2>&1;
                  #killall 4s-backend >/dev/null 2>&1;;
                  echo "$1 reload not available yet.";;
    "all")        otreload algorithm;
                  otreload compound;
                  otreload dataset;
                  otreload feature;
                  otreload model;
                  otreload task;
                  #otrelaod validation;
                  otreload 4store;;
    *)            echo "One argument required: [service_name] or 'all'";
                  echo "usage: otreload [all|algorithm|compound|dataset|feature|model|task|validation|4store]";
                  return 1;;
  esac
}

# kill unicorn
# @param1 integer Port
# @example kill_unicorn 8081
kill_unicorn() {
  for p in `ps x | grep 'unicorn' | grep $1 | grep -v grep | awk '{print $1}'`; do kill -3 $p; done;  
}

# Kill the server
otkill() {
  if [ $# != 1 ]
  then
    echo "One argument required: [service_name] or 'all'"
    echo "usage: otkill [all|algorithm|compound|dataset|feature|model|task|validation|4store]"
    return 1
  fi 

  otconfig
  case "$1" in
    "algorithm")  kill_unicorn 8081;;
    "compound")   kill_unicorn 8082;;
    "dataset")    kill_unicorn 8083;;
    "feature")    kill_unicorn 8084;;
    "model")      kill_unicorn 8085;;
                  echo "$1 not available yet.";;
    "task")       kill_unicorn 8086;;
    "validation") #kill_unicorn 8087;;
                  echo "$1 not available yet.";;
    "4store")     killall 4s-httpd >/dev/null 2>&1;
                  killall 4s-backend >/dev/null 2>&1;;
    "all")        otkill algorithm;
                  otkill compound;
                  otkill dataset;
                  otkill feature;
                  otkill model;
                  otkill task;
                  #otkill validation;
                  otkill 4store;;
    *)            echo "One argument required: [service_name] or 'all'";
                  echo "usage: otkill [all|algorithm|compound|dataset|feature|model|task|validation|4store]";
                  return 1;;
  esac
}

# get service uri
# sets $SERVICE_URI if found in config files
# @param1 string [service_name]
# @example get_service_uri algorithm
get_service_uri() {
  if [ $# != 1 ]
  then
    echo "One argument required: [service_name]"
    echo "usage: get_service_uri [algorithm|compound|dataset|feature|model|task|validation|four_store]"
    return 1
  fi
  SERVICE_URI=""

  if [ -f $HOME/.opentox/config/$1.rb ]
  then
    SERVICE_URI=`cat $HOME/.opentox/config/$1.rb | grep $1 | grep "uri" | awk -F":uri => " '{print $2}' | awk -F" " '{print $1}' | awk -F"," '{print $1}' |  sed "s/'//g" | sed 's/"//g'`
  fi

  if [ -f $HOME/.opentox/config/default.rb ]
  then
    [ -n "$SERVICE_URI" ] || SERVICE_URI=`cat $HOME/.opentox/config/default.rb | grep $1 | grep "uri" | awk -F":uri => " '{print $2}' | awk -F" " '{print $1}' | awk -F"," '{print $1}' |  sed "s/'//g" | sed 's/"//g'`
  fi
  
  if [ -z "$SERVICE_URI" ] 
  then 
    echo "Cannot find service uri for $1 in config files."
    return 1
  else
    return 0
  fi
}

# check service
# @param1 string [service_name]
# @example check_service algorithm
check_service() {
  if [ $# != 1 ]
  then
    echo "One argument required: [service_name]"
    echo "usage: get_service_uri [algorithm|compound|dataset|feature|model|task|validation|four_store]"
    return 1
  fi
  get_service_uri $1
  if [ $1 == "four_store" ]
  then
    SERVICE_URI="$SERVICE_URI""/status/"
  fi
  if [ -n "`curl -v $SERVICE_URI 2>&1 | grep '200 OK'`" ]
  then
    return 0 
  else
    echo "$1 is not available at $SERVICE_URI."
    return 1
  fi
}

# Check the server
otcheck() {
  if [ $# != 1 ]
  then
    echo "One argument required: [service_name] or 'all'"
    echo "usage: otcheck [all|algorithm|compound|dataset|feature|model|task|validation|4store]"
    return 1
  fi

  otconfig
  case "$1" in
    "algorithm")  check_service "algorithm";;
    "compound")   check_service "compound";;
    "dataset")    check_service "dataset";;
    "feature")    check_service "feature";;
    "model")      check_service "model";;
    "task")       check_service "task";;
    "validation") #check_service "validation";;
                  echo "$1 not available yet.";;
    "4store")     check_service "four_store";; 
    "all")        otcheck "algorithm";
                  otcheck "compound";
                  otcheck "dataset";
                  otcheck "feature";
                  otcheck "model";
                  otcheck "task";
                  #otcheck "validation";
                  otcheck 4store;;
    *)            echo "One argument required: [service_name] or 'all'";
                  echo "usage: otcheck [all|algorithm|compound|dataset|feature|model|task|validation|4store]";
                  return 1;;
  esac
}

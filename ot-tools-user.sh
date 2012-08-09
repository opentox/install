# Some useful scripts to put in your ~/.bashrc in case you are using bash (assuming OT_PREFIX is '~/opentox-ruby')

# Load server config
otconfig() {
  source $HOME/.opentox/opentox-ui.sh
}


# Start unicorn
# @param1 [service_name] 
# @param2 integer Port
# @example start_unicorn algorithm 8081
start_unicorn() {
  cd $HOME/opentox-ruby/$1
  nice bash -c "nohup unicorn -p $2 >/dev/null 2>&1 &"
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
    "algorithm") 
      start_unicorn $1 8081;;
    "compound") 
      echo "$1 not available yet.";;
      #start_unicorn $1 8082;;
    "dataset")
      start_unicorn $1 8083;;
    "feature")
      start_unicorn $1 8084;;
    "model") 
      echo "$1 not available yet.";;
      #start_unicorn $1 8085;;
    "task")
      start_unicorn $1 8086;;
    "validation") 
      echo "$1 not available yet.";;
      #start_unicorn $1 8087;;
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
    *)
      echo "One argument required: [service_name] or 'all'";
      echo "usage: otstart [all|algorithm|compound|dataset|feature|model|task|validation|4store]";
      return 1;
      ;;
  esac
  cd $DIR
}

# Display log
alias otless='less $HOME/.opentox/log/development.log'

# Tail log
alias ottail='tail -f $HOME/.opentox/log/development.log'

# kill unicorn
# @param1 integer Port
# @example kill_unicorn 8081
kill_unicorn() {
  for p in `ps x | grep 'unicorn' | grep $1 | grep -v grep | awk '{print $1}'`; do kill -9 $p; done;  
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
    "algorithm") kill_unicorn 8081;;
    "compound") #kill_unicorn 8082;;
      echo "$1 not available yet.";;
    "dataset") kill_unicorn 8083;;
    "feature") kill_unicorn 8084;;
    "model") #kill_unicorn 8085;;
      echo "$1 not available yet.";;
    "task") kill_unicorn 8086;;
    "validation") #kill_unicorn 8087;;
      echo "$1 not available yet.";;
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
    *)
      echo "One argument required: [service_name] or 'all'";
      echo "usage: otkill [all|algorithm|compound|dataset|feature|model|task|validation|4store]";
      return 1;
      ;;
  esac
}

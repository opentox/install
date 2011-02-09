#!/bin/sh

echo "Initializing MySql"
. ./config
password=`grep password /home/opentox/.opentox/config/production.yaml | sed 's/\.*:password://' | tr -d ' '`
mysql -u root -p$mysql_root << EOF
  DROP DATABASE IF EXISTS $branch;
  CREATE DATABASE production;
  GRANT ALL PRIVILEGES ON production.* TO production@localhost IDENTIFIED BY "$password";
  FLUSH PRIVILEGES;
EOF


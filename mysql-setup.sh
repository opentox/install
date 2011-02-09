#!/bin/sh

echo "Initializing MySql"
. ./config
mysql -u root -p$mysql_root << EOF
  DROP DATABASE IF EXISTS $branch;
  CREATE DATABASE production;
  GRANT ALL PRIVILEGES ON production.* TO production@localhost IDENTIFIED BY "$password";
  FLUSH PRIVILEGES;
EOF


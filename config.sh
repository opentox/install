#!/bin/sh
#
# Configuration file for Opentox installer.
# Author: Christoph Helma, Andreas Maunz.
#

# 1) Base setup
OT_DIST="debian"       # Linux distribution    (debian)
OT_INSTALL="local"     # Type                  (gem, local, server)
OT_BRANCH="master"     # Maturity              (development, master)

# 2) Where all binaries are installed.
PREFIX="$HOME/opentox"
JAVA_HOME="/usr/lib/jvm/java-6-sun"

# 3) What versions to install.
RUBY_NUM_VER="1.8.7-2011.03"
OB_NUM_VER="2.2.3"
KL_NUM_VER="0.9-11"
REDIS_NUM_VER="2.2.2"

# 4) Server settings.
NGINX_SERVERNAME="localhost"
WWW_DEST="$PREFIX/www"

# 4) Done.


### Nothing to gain from changes below this line.
JAVA_CONF="$PREFIX/.bash_java_ot"
RUBY_CONF="$PREFIX/.bash_ruby_ot"
REDIS_CONF="$PREFIX/.bash_redis_ot"
OB_CONF="$PREFIX/.bash_OB_ot"
KL_CONF="$PREFIX/.bash_R_ot"

RUBY_VER="ruby-enterprise-$RUBY_NUM_VER"
OB_VER="openbabel-$OB_NUM_VER"
KL_VER="$KL_NUM_VER"
REDIS_VER="$REDIS_NUM_VER"

RUBY_DEST="$PREFIX/$RUBY_VER"
OB_DEST="$PREFIX/$OB_VER"
OB_DEST_BINDINGS="$PREFIX/openbabel-ruby-install"
KL_DEST="$PREFIX/r-packages"
NGINX_DEST="$PREFIX/nginx"
REDIS_DEST="$PREFIX/redis-$REDIS_VER"

REDIS_SERVER_CONF="$REDIS_DEST/redis.conf"


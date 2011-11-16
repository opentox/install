#!/bin/sh
#
# Configuration file for Opentox installer.
# Author: Christoph Helma, Andreas Maunz.
#

# 1) Base setup
OT_DIST="debian"       # Linux distribution    (debian)
OT_INSTALL="local"     # Type                  (gem, local, server)
OT_BRANCH="development"     # Maturity              (development -you need SSH key at Github-, master)

# 2) Where all binaries are installed.
OT_PREFIX="$HOME/opentox-ruby"
OT_JAVA_HOME="/usr/lib/jvm/java-6-sun"

# 3) What versions to install.
RUBY_NUM_VER="1.8.7-2011.03"
OB_NUM_VER="2.2.3"
KL_NUM_VER="0.9-11"
REDIS_NUM_VER="2.2.2"

# 4) Server settings.
NGINX_SERVERNAME="toxcreate3.in-silico.ch"
WWW_DEST="$OT_PREFIX/www"
PORT=":8081" # set to empty string ("") for port 80 otherwise set to port *using colon* e.g. ":8080"
OHM_PORT="6379" # set to port (no colon)

# Done.


### Nothing to gain from changes below this line.
JAVA_CONF="$OT_PREFIX/.sh_java_ot"
RUBY_CONF="$OT_PREFIX/.sh_ruby_ot"
REDIS_CONF="$OT_PREFIX/.sh_redis_ot"
NGINX_CONF="$OT_PREFIX/.sh_nginx_ot"
OB_CONF="$OT_PREFIX/.sh_OB_ot"
KL_CONF="$OT_PREFIX/.sh_R_ot"

RUBY_VER="ruby-enterprise-$RUBY_NUM_VER"
OB_VER="openbabel-$OB_NUM_VER"
KL_VER="$KL_NUM_VER"
REDIS_VER="$REDIS_NUM_VER"

RUBY_DEST="$OT_PREFIX/$RUBY_VER"
OB_DEST="$OT_PREFIX/$OB_VER"
OB_DEST_BINDINGS="$OT_PREFIX/openbabel-ruby-install"
KL_DEST="$OT_PREFIX/r-packages"
NGINX_DEST="$OT_PREFIX/nginx"
REDIS_DEST="$OT_PREFIX/redis-$REDIS_VER"

REDIS_SERVER_CONF="$REDIS_DEST/redis.conf"
OT_UI_CONF="$HOME/.opentox-ui.sh"

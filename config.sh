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
OT_JAVA_HOME="/usr/lib/jvm/java-6-openjdk"

# 3) What versions to install.
RUBY_NUM_VER="1.9.3-p125"
OB_NUM_VER="2.3.1"
REDIS_NUM_VER="2.2.2"

# 4) Server settings.
NGINX_SERVERNAME="toxcreate3.in-silico.ch"
WWW_DEST="$OT_PREFIX/www"
UNICORN_PORT="" # set to empty string ("") for port 80 otherwise set to port *using colon* e.g. ":8080"
OHM_PORT="" # set to port (no colon)

# Done.


### Nothing to gain from changes below this line.
JAVA_CONF="$OT_PREFIX/.sh_java_ot"
OB_CONF="$OT_PREFIX/.sh_OB_ot"
R_CONF="$OT_PREFIX/.sh_R_ot"

OB_VER="openbabel-$OB_NUM_VER"
REDIS_VER="$REDIS_NUM_VER"

OB_DEST="$OT_PREFIX/$OB_VER"
OB_DEST_BINDINGS="$OT_PREFIX/openbabel-ruby-install"
R_DEST="$OT_PREFIX/r-packages"
REDIS_DEST="$OT_PREFIX/redis-$REDIS_VER"

REDIS_SERVER_CONF="$REDIS_DEST/redis.conf"
OT_UI_CONF="$HOME/.opentox-ui.sh"

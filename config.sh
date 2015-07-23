#!/bin/sh

# Configuration file for Opentox installer.
# Author: Christoph Helma, Andreas Maunz.


# 1) Base setup
OT_DIST="debian"            # Linux distribution    (debian, ubuntu)
OT_INSTALL="local"          # Type                  (gem, local, server)
OT_BRANCH="development"     # Maturity              (development -need SSH key at Github-, master)

# 2) Where binaries are installed
OT_PREFIX="$HOME/opentox-ruby"
OT_JAVA_HOME="/usr/lib/jvm/java-7-openjdk" # use "/usr/lib/jvm/java-7-openjdk-amd64" for 64bit system architecture

# 3) What versions to install

RAPTOR2_NUM_VER="2.0.15"
RASQAL_NUM_VER="0.9.33"
# RUBY_NUM_VER="2.0.0-p481"
RUBY_NUM_VER="2.2.2"
FOUR_STORE_VER="4store-v1.1.5"
REDLAND_DWL="http://download.librdf.org"
REDLAND_APT_KEY="https://www.dajobe.org/gnupg.asc"
FOUR_STORE_URL="http://4store.org/download"

# 4) Server settings.
OHM_PORT="6379" # set to port (no colon)

# 5) Backend name.
BACKEND_NAME="opentox"

# Done.

### Nothing to gain from changes below this line.
JAVA_CONF="$HOME/.opentox/java.sh"
FST_CONF="$HOME/.opentox/4S.sh"
RAPTOR2_CONF="$HOME/.opentox/RAPTOR2.sh"
RASQAL_CONF="$HOME/.opentox/RASQAL.sh"
REDIS_CONF="$HOME/.opentox/REDIS.sh"
OT_UI_CONF="$HOME/.opentox/opentox-ui.sh"
OT_TOOLS_CONF="$HOME/.opentox/ot-tools.sh"
OT_DEFAULT_CONF="$HOME/.opentox/config/default.rb"

RAPTOR2_VER="raptor2-$RAPTOR2_NUM_VER"
RASQAL_VER="rasqal-$RASQAL_NUM_VER"
RUBY_DWL="http://ftp.ruby-lang.org/pub/ruby/2.2"
RAPTOR2_DWL="$REDLAND_DWL/source/$RAPTOR2_VER.tar.gz"
RASQAL_DWL="$REDLAND_DWL/source/$RASQAL_VER.tar.gz"
REDLAND_DEB="$REDLAND_DWL/binaries/$OT_DIST/unstable"
FOUR_STORE_DWL="$FOUR_STORE_URL/$FOUR_STORE_VER.tar.gz"

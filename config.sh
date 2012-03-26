#!/bin/sh

# Configuration file for Opentox installer.
# Author: Christoph Helma, Andreas Maunz.


# 1) Base setup
OT_DIST="debian"            # Linux distribution    (debian)
OT_INSTALL="local"          # Type                  (gem, local, server)
OT_BRANCH="development"     # Maturity              (development -need SSH key at Github-, master)

# 2) Where all binaries are installed.
OT_PREFIX="$HOME/opentox-ruby"
OT_JAVA_HOME="/usr/lib/jvm/java-6-openjdk"

# 3) What versions to install.
RUBY_NUM_VER="1.9.3-p125"
OB_NUM_VER="2.3.1"

# 4) Server settings.
SERVERNAME="toxcreate3.in-silico.ch"

# Done.


### Nothing to gain from changes below this line.
JAVA_CONF="$HOME/.opentox/sh_java"
OB_CONF="$HOME/.opentox/sh_OB"
R_CONF="$HOME/.opentox/sh_R"
OT_UI_CONF="$HOME/.opentox/opentox-ui.sh"

OB_VER="openbabel-$OB_NUM_VER"
OB_DEST="$OT_PREFIX/$OB_VER"
OB_DEST_BINDINGS="$OT_PREFIX/openbabel-ruby-install"


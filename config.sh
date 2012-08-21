#!/bin/sh

# Configuration file for Opentox installer.
# Author: Christoph Helma, Andreas Maunz.


# 1) Base setup
OT_DIST="debian"            # Linux distribution    (debian, ubuntu)
OT_INSTALL="local"          # Type                  (gem, local, server)
OT_BRANCH="development"     # Maturity              (development -need SSH key at Github-, master)

# 2) Where binaries are installed
OT_PREFIX="$HOME/opentox-ruby"
OT_JAVA_HOME="/usr/lib/jvm/java-6-openjdk"

# 3) What versions to install

OB_NUM_VER="2.3.1"
RAPTOR2_NUM_VER="2.0.8"
RASQAL_NUM_VER="0.9.29"
RUBY_NUM_VER="1.9.3-p194"
REDLAND_DWL="http://download.librdf.org"
REDLAND_APT_KEY="http://purl.org/net/dajobe/gnupg.asc"

# Done.

### Nothing to gain from changes below this line.
JAVA_CONF="$HOME/.opentox/java.sh"
FST_CONF="$HOME/.opentox/4S.sh"
OB_CONF="$HOME/.opentox/OB.sh"
R_CONF="$HOME/.opentox/R.sh"
RAPTOR2_CONF="$HOME/.opentox/RAPTOR2.sh"
RASQAL_CONF="$HOME/.opentox/RASQAL.sh"
OT_UI_CONF="$HOME/.opentox/opentox-ui.sh"
OT_TOOLS_CONF="$HOME/.opentox/ot-tools.sh"
OT_DEFAULT_CONF="$HOME/.opentox/config/default.rb"

OB_VER="openbabel-$OB_NUM_VER"
RAPTOR2_VER="raptor2-$RAPTOR2_NUM_VER"
RASQAL_VER="rasqal-$RASQAL_NUM_VER"
OB_DEST="$OT_PREFIX/$OB_VER"
OB_DEST_BINDINGS="$OT_PREFIX/openbabel-ruby-install"
RUBY_DWL="http://ftp.ruby-lang.org/pub/ruby/1.9"
RUBY_DIR="$HOME/.rbenv/versions/$RUBY_NUM_VER"
RAPTOR2_DWL="$REDLAND_DWL/source/$RAPTOR2_VER.tar.gz"
RASQAL_DWL="$REDLAND_DWL/source/$RASQAL_VER.tar.gz"
REDLAND_DEB="$REDLAND_DWL/binaries/$OT_DIST/unstable"

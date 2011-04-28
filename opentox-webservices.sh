#!/bin/sh
#
# Installs Opentox Webservices.
# Author: Christoph Helma, Andreas Maunz.
#

. "`pwd`/utils.sh"
DIR=`pwd`

if [ "$(id -u)" = "0" ]; then
  echo "This script must be run as non-root." 1>&2
  exit 1
fi

# Utils
WGET="`which wget`"
if [ ! -e "$WGET" ]; then
  echo "'wget' missing. Install 'wget' first. Aborting..."
  exit 1
fi

RAKE="`which rake`"
if [ ! -e "$RAKE" ]; then
  echo "'rake' missing. Install 'rake' first. Aborting..."
  exit 1
fi

GIT="`which git`"
if [ ! -e "$GIT" ]; then
  echo "'git' missing. Install 'git' first. Aborting..."
  exit 1
fi

LOG="/tmp/`basename $0`-log.txt"

if ! id opentox >>$LOG 2>&1; then
  cmd="sudo adduser --system opentox" && run_cmd "$cmd" "User 'opentox'"
fi

echo
echo "Webservices ('$LOG'):"

mkdir -p "$WWW_DEST/opentox" >>$LOG 2>&1
cd "$WWW_DEST/opentox" >>$LOG 2>&1
for s in compound dataset algorithm model toxcreate task; do
    rm -rf "$s" >>$LOG 2>&1
    $GIT clone "git://github.com/opentox/$s.git" "$s" >>$LOG 2>&1
    cd "$s" >>$LOG 2>&1
    $GIT checkout -b $OT_BRANCH origin/$OT_BRANCH >>$LOG 2>&1
    #rm -rf public >>$LOG 2>&1
    #mkdir public >>$LOG 2>&1
    mypath_from="$WWW_DEST/opentox/$s/public"
    mypath_to="$WWW_DEST/$s"
    cmd="ln -sf \"$mypath_from\" \"$mypath_to\"" && run_cmd "$cmd" "Linking $s"
    cd - >>$LOG 2>&1
done

# validation service
#git clone http://github.com/mguetlein/opentox-validation.git validation
#cd /var/www/opentox/validation
#git checkout -t origin/test
#gem install ruby-plot
#mkdir -p public
#ln -s /var/www/opentox/validation/public /var/www/validation

# fminer etc
cmd="test -f $HOME/.opentox/config/production.yaml" && run_cmd "$cmd" "Config present"
cd "$WWW_DEST/opentox/algorithm" >>$LOG 2>&1
cmd="$GIT submodule init" && run_cmd "$cmd" "Fminer Init"
cmd="$GIT submodule update" && run_cmd "$cmd" "Fminer Update"
for mylib in bbrc last; do
  cmd="sed -i 's,^INCLUDE_OB.*,INCLUDE_OB\ =\ -I$OB_DEST/include/openbabel-2.0,g' $WWW_DEST/opentox/algorithm/libfminer/lib$mylib/Makefile; sed -i 's,^LDFLAGS_OB.*,LDFLAGS_OB\ =\ -L$OB_DEST/lib,g' $WWW_DEST/opentox/algorithm/libfminer/lib$mylib/Makefile" && run_cmd "$cmd" "Makefile $mylib (OB)"
  cmd="sed -i 's,^INCLUDE_RB.*,INCLUDE_RB\ =\ -I$RUBY_DEST/lib/ruby/1.8/`uname -m`-linux,g' $WWW_DEST/opentox/algorithm/libfminer/lib$mylib/Makefile" && run_cmd "$cmd" "Makefile $mylib (RB)"
done
cd "libfminer/libbbrc">>$LOG 2>&1
$GIT checkout master >>$LOG 2>&1
$GIT pull >>$LOG 2>&1
cmd="make ruby" && run_cmd "$cmd" "Make BBRC"
cd ->>$LOG 2>&1
cd "libfminer/liblast">>$LOG 2>&1
$GIT checkout master >>$LOG 2>&1
$GIT pull >>$LOG 2>&1
cmd="make ruby" && run_cmd "$cmd" "Make LAST"
cd ->>$LOG 2>&1
cd "last-utils">>$LOG 2>&1
$GIT checkout master >>$LOG 2>&1
$GIT pull >>$LOG 2>&1

cd "$DIR"


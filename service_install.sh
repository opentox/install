. $HOME/.opentox/config/install/config.sh
. $OT_PREFIX/install/utils.sh
. $HOME/.opentox/ot-tools.sh
otconfig
for f in opentox-client opentox-server; do
  git clone "https://github.com/opentox/$f.git" $OT_PREFIX/$f
  cd $OT_PREFIX/$f
  git checkout development 2>/dev/null
done
cd $OT_PREFIX/opentox-client/bin
./opentox-client-install silent
cd $OT_PREFIX/opentox-server/bin
./opentox-server-install silent

for f in task; do
  git clone "https://github.com/opentox/$f.git" $OT_PREFIX/$f
  cd $OT_PREFIX/$f
  git checkout development 2>/dev/null
  if [ -f $OT_PREFIX/$f/bin/$f-install ]; then
    cd $OT_PREFIX/$f/bin
    ./$f-install silent
  fi
done
notify

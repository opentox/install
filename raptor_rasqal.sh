wget http://download.librdf.org/source/raptor2-2.0.8.tar.gz
tar xvzf raptor2-2.0.8.tar.gz
cd raptor2-2.0.8
./configure
make
sudo make install
sudo /sbin/ldconfig
cd

wget http://download.librdf.org/source/rasqal-0.9.29.tar.gz
tar xvzf rasqal-0.9.29.tar.gz
cd rasqal-0.9.29
./configure
make
sudo make install
sudo /sbin/ldconfig
cd

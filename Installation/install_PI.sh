# dep
sudo apt install build-essential autoconf libtool
# fetch source code
git clone https://github.com/p4lang/PI.git
cd PI && git submodule update --init --recursive 

# install dependencies
sudo apt install libjudy-dev libreadline-dev 

./autogen.sh 
./configure --with-bmv2 --with-proto --with-sysrepo
make && make check 
sudo make install 

sudo ldconfig
# back to tools/
cd ..
# fetch bmv2 source code
git clone https://github.com/p4lang/behavioral-model.git bmv2 && cd bmv2/
# get all dependencies
sudo apt install automake cmake libjudy-dev libgmp-dev libpcap-dev libboost-dev libboost-test-dev libboost-program-options-dev libboost-system-dev libboost-filesystem-dev libboost-thread-dev libevent-dev libtool flex bison pkg-config g++ libssl-dev

# using install_dep.sh
./install_dep.sh
# autogen & configure
./autogen.sh
# enable simple_switch enter debugger mode
./configure --enable-debugger --with-pi
# compile 
make 
# install 
sudo make install

sudo ldconfig
# back to tools/
cd ..
# dependencies
sudo apt-get install g++ git automake libtool libgc-dev bison flex libfl-dev libgmp-dev libboost-dev libboost-iostreams-dev libboost-graph-dev pkg-config python python-scapy python-ipaddr tcpdump cmake
# fetch p4c 
git clone --recursive https://github.com/p4lang/p4c.git

cd p4c
mkdir build && cd build
cmake .. -DMAKE_BUILD_TYPE=RELEASE
make -j4 

# check installation
make -j4 check

# install 
sudo make install

sudo ldconfig
# back to tools/
cd ../..
# install dep
sudo apt install build-essential cmake libpcre3-dev libavl-dev libev-dev libprotobuf-c-dev protobuf-c-compiler

# -- libyang
git clone https://github.com/CESNET/libyang.git
cd libyang
git checkout v0.14-r1
mkdir build && cd build
cmake ..
make
sudo make install

# back
cd ..

# -- sysrepo 
git clone https://github.com/sysrepo/sysrepo.git
cd sysrepo
git checkout v0.7.2
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=Off -DCALL_TARGET_BINS_DIRECTLY=Off ..
make
sudo make install

# back
cd ..
# mkdir tools
mkdir -p tools && cd tools/
# ========================== build p4c ========================== #
git clone --recursive https://github.com/p4lang/p4c.git

cd p4c
mkdir build && cd build
cmake .. -DMAKE_BUILD_TYPE=RELEASE
make -j4 

# check installation
# make -j4 check

# install 
sudo make install

# back to tools/
cd ../..

# ========================== build bmv2 ========================== #
# fetch nanomsg source code
git clone https://github.com/nanomsg/nanomsg.git

# build from source
cd nanomsg/
mkdir build && cd build/
cmake ..
cmake --build .
ctest .
sudo cmake --build . --target install 
sudo ldconfig

# back to tools/
cd ../..

# fetch bmv2 source code
git clone https://github.com/p4lang/behavioral-model.git bmv2
cd bmv2/

# get all dependencies
sudo apt install automake cmake libjudy-dev libgmp-dev libpcap-dev libboost-dev libboost-test-dev libboost-program-options-dev libboost-system-dev libboost-filesystem-dev libboost-thread-dev libevent-dev libtool flex bison pkg-config g++ libssl-dev

# using install_dep.sh
./install_dep.sh
# install dependencies for thrift
./travis/install_thrift.sh 


# autogen & configure
./autogen.sh
./configure
# compile 
make 
# install 
sudo make install

# back to tools/
cd ..

# ========================== build PI ========================== #
# install grpc
sudo apt install build-essential autoconf libtool
git clone -b $(curl -L https://grpc.io/release) https://github.com/grpc/grpc
cd grpc 
git submodule update --init 

# build protocol buffer 
cd third_party/protobuf
make && sudo make install 

# back to grpc repo
cd ../..

# make 
make 
sudo make install 

# back to tools/
cd ..

# fetch source code
git clone https://github.com/p4lang/PI.git
cd PI && git submodule update --init --recursive 

# install dependencies
sudo apt install libjudy-dev libreadline-dev 

./autogen.sh 
./configure 
make && make check 
sudo make install 

# back to tools/
cd ..
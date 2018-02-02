# fetch source code
git clone -b $(curl -L https://grpc.io/release) https://github.com/grpc/grpc 
cd grpc/
# update 
git submodule update --init
# dep
sudo apt-get install build-essential autoconf libtool
# make 
make && make install

# also go to third party - protocol buffer to install
sudo apt-get install autoconf automake libtool curl make g++ unzip

cd third_party/protobuf
# gen
./autogen.sh
./configure
# build
make && make check
# install 
sudo make install 
# refresh shared library cache
sudo ldconfig

# back to root 
cd ../../..
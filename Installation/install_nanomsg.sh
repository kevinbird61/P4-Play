# nanomsg
# fetch nanomsg source code
git clone https://github.com/nanomsg/nanomsg.git

# build from source
cd nanomsg/
mkdir build && cd build/
cmake .. && cmake --build . && ctest .
sudo cmake --build . --target install 
sudo ldconfig

# back to tools/
cd ../..
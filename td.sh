#!/bin/bash 
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install make git zlib1g-dev libssl-dev gperf php cmake clang-10 libc++-dev libc++abi-dev
git clone https://github.com/tdlib/td.git
cd td
rm -rf build
mkdir build
cd build
export CXXFLAGS="-stdlib=libc++"
CC=/usr/bin/clang-10 CXX=/usr/bin/clang++-10 cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=../tdlib -DTD_ENABLE_LTO=ON -DCMAKE_AR=/usr/bin/llvm-ar-10 -DCMAKE_NM=/usr/bin/llvm-nm-10 -DCMAKE_OBJDUMP=/usr/bin/llvm-objdump-10 -DCMAKE_RANLIB=/usr/bin/llvm-ranlib-10 ..
cmake --build . --target install
cd ..
cd ..
ls -l td/tdlib

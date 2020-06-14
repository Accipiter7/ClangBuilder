#!/bin/bash

sudo apt -y update && sudo apt -y install ninja-build cmake clang-10 lld-10

export wd=`pwd`

git clone https://github.com/llvm/llvm-project/ -b release/10.x src
procs=8

cd src || exit

mkdir build1 && cd build1
mkdir objects 

export CXX=clang++
export CC=clang

cmake ../llvm -G "Ninja" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCLANG_ENABLE_ARCMT=OFF  \
	-DLLVM_CCACHE_BUILD=OFF \
	-DCLANG_ENABLE_STATIC_ANALYZER=OFF \
	-DCMAKE_C_FLAGS="-march=native -O3 -g0 -DNDEBUG" \
	-DCMAKE_CXX_FLAGS="-march=native -O3 -g0 -DNDEBUG" \
	-DCLANG_PLUGIN_SUPPORT=OFF \
	-DLLVM_ENABLE_BINDINGS=OFF  \
	-DLLVM_ENABLE_PLUGINS=ON \
	-DLLVM_ENABLE_OCAMLDOC=OFF \
	-DLLVM_ENABLE_TERMINFO=OFF \
	-DLLVM_INCLUDE_DOCS=OFF \
	-DLLVM_INCLUDE_EXAMPLES=OFF \
	-DCMAKE_INSTALL_PREFIX="${wd}/src/build1" \
	-DLLVM_TARGETS_TO_BUILD="host" \
	-DLLVM_USE_LINKER=lld \
	-DLLVM_ENABLE_PROJECTS="clang;lld" \
	-DCOMPILER_RT_BUILD_SANITIZERS=OFF \
	-DLLVM_ENABLE_BACKTRACES=OFF \
	-DLLVM_ENABLE_WARNINGS=OFF  \
	-DLLVM_INCLUDE_TESTS=OFF \
	-DLLVM_INCLUDE_UTILS=OFF

sudo nice -n -20 ninja -l $procs -j $procs all || exit
cd ..
mkdir out
mkdir build2 && cd build2


export CXX="${wd}/src/build1/bin/clang++"
export CC="${wd}/src/build1/bin/clang"

cmake ../llvm -G "Ninja" \
	-DCMAKE_AR=${wd}/src/build1/bin/llvm-ar \
	-DCLANG_TABLEGEN=${wd}/src/build1/bin/clang-tblgen \
	-DLLVM_TABLEGEN=${wd}/src/build1/bin/llvm-tblgen \
	-DCMAKE_RANLIB=${wd}/src/build1/bin/llvm-ranlib \
	-DCMAKE_BUILD_TYPE=Release \
	-DCLANG_ENABLE_ARCMT=OFF  \
	-DCLANG_ENABLE_STATIC_ANALYZER=OFF \
	-DCLANG_PLUGIN_SUPPORT=OFF \
	-DLLVM_ENABLE_BINDINGS=OFF  \
	-DLLVM_ENABLE_PLUGINS=ON \
	-DLLVM_ENABLE_OCAMLDOC=OFF \
	-DLLVM_ENABLE_TERMINFO=OFF \
	-DLLVM_INCLUDE_DOCS=OFF \
	-DLLVM_INCLUDE_EXAMPLES=OFF \
	-DCMAKE_INSTALL_PREFIX="${wd}/src/out" \
	-DLLVM_TARGETS_TO_BUILD="ARM;AArch64" \
	-DLLVM_USE_LINKER=${wd}/src/build1/bin/ld.lld \
	-DLLVM_ENABLE_PROJECTS="clang;lld" \
	-DLLVM_ENABLE_BACKTRACES=OFF \
	-DLLVM_ENABLE_WARNINGS=OFF  \
	-DLLVM_INCLUDE_TESTS=OFF \
	-DLLVM_INCLUDE_UTILS=OFF \
	-DLLVM_ENABLE_LTO=full
	
	
nice -n -15 ninja -l $procs -j $procs all || exit
nice -n -15 ninja -l $procs -j $procs install || exit

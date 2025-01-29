#!/bin/bash

git submodule update --init
pushd .
cd ./matter_sdk
./scripts/checkout_submodules.py --shallow --platform  linux
source ./scripts/activate.sh
popd

# cd matter_plugin/certifier-tool
# rm -rf out
# sync main.cpp
# sync BUILD.gn
# remove all symbolic links
# for d in ../../matter_sdk/examples/chip-tool/*; do ln -s "$d" './'; done
# for d in ../../matter_sdk/examples/chip-tool/.*; do ln -s "$d" './'; done
# cd ../../matter_plugin/certifier-all-clusters-app
# rm -rf out
# sync main.cpp
# sync BUILD.gn
# remove all symbolic links
# for d in ../../matter_sdk/examples/all-clusters-app/linux/*; do ln -s "$d" './'; done
# for d in ../../matter_sdk/examples/all-clusters-app/linux/.*; do ln -s "$d" './'; done
# cd ../..

mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/ -DENABLE_CMAKE_VERBOSE_MAKEFILE=ON -DENABLE_CMOCKA=OFF -DENABLE_MBEDTLS=OFF -DENABLE_TESTS=ON -DCMAKE_BUILD_TYPE=Debug -DENABLE_MATTER_EXAMPLES=ON -DSYSTEMV_DAEMON=OFF
make
cd ..
cp build/libcertifier.a ./matter_plugin/certifier-tool
cp build/libcertifier.a ./matter_plugin/certifier-all-clusters-app

pushd .

cd build
./certifierUtil get-cert -f -k seed.p12 -p changeit -o dac-commissioner.p12 --product-id 4353 --profile-name XFN_DL_PAI_1_Class_3
./certifierUtil get-cert -f -k seed.p12 -p changeit -o dac-commissionee.p12 --product-id 4353 --profile-name XFN_DL_PAI_1_Class_3

cd ../matter_plugin/certification-declaration-gen
make install all PRODUCT_ID=4353 VENDOR_ID=65524
cp *.array ../common/

cd ../certifier-tool
gn gen --check out/build
ninja -C out/build

cd ./out/build
cp certifier-tool ../../../../build

cd ../../../certifier-all-clusters-app
gn gen --check out/build
ninja -C out/build

cd ./out/build
cp certifier-all-clusters-app ../../../../build

cd ../..
cp trafficlight ../../build

popd

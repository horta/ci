#!/usr/bin/env bash

set -e
set -o xtrace

bash <(curl -fsSL https://raw.githubusercontent.com/horta/ci/master/check-version.sh)

mkdir build && pushd build
cmake .. -DCMAKE_INSTALL_PREFIX=$TRAVIS_BUILD_DIR -DCMAKE_BUILD_TYPE=Release
make && make test && make install
popd && rm -rf build
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then test -e $TRAVIS_BUILD_DIR/lib/lib$PKG_NAME.so; fi
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then test -e $TRAVIS_BUILD_DIR/lib/lib${PKG_NAME}_static.a; fi
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then test -e $TRAVIS_BUILD_DIR/include/$PKG_NAME.h; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then test -e $TRAVIS_BUILD_DIR/lib/lib$PKG_NAME.dylib; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then test -e $TRAVIS_BUILD_DIR/lib/lib${PKG_NAME}_static.a; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then test -e $TRAVIS_BUILD_DIR/include/$PKG_NAME.h; fi
bash <(curl -fsSL https://raw.githubusercontent.com/limix/$PKG_NAME/master/install)

cd $TRAVIS_BUILD_DIR


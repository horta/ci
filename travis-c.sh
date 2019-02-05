#!/usr/bin/env bash

set -e

function finish {
	rv=$?

    if [ "$rv" != "0" ]
    then
        echo -e "\e[31mERROR!\e[39m"
    else
        echo -e "\e[32mSuccess!\e[39m"
    fi

    return $rv
}
trap finish EXIT

function testit {
    [ -z "$PKG_NAME" ] && PKG_NAME=$(cat NAME)

    bash <(curl -fsSL https://raw.githubusercontent.com/horta/ci/master/check-version.sh)

    mkdir build 2>/dev/null || true
    pushd build
    [ -z "$TRAVIS_BUILD_DIR" ] && BUILD_DIR=$(mktemp -d) || BUILD_DIR=$TRAVIS_BUILD_DIR
    cmake .. -DCMAKE_INSTALL_PREFIX=$BUILD_DIR -DCMAKE_BUILD_TYPE=Release
    make && make test && make install
    popd && rm -rf build

    if [ -z "$TRAVIS_OS_NAME" ]
    then
        OS_NAME=$(echo $(uname) | awk '{print tolower($0)}')
        [ "$OS_NAME" = "darwin" ] && OS_NAME=osx
        echo $OS_NAME
    else
        OS_NAME=$TRAVIS_OS_NAME
    fi

    if [[ "$OS_NAME" == "linux" ]]; then test -e $BUILD_DIR/lib/lib$PKG_NAME.so; fi
    if [[ "$OS_NAME" == "linux" ]]; then test -e $BUILD_DIR/lib/lib${PKG_NAME}_static.a; fi
    if [[ "$OS_NAME" == "linux" ]]; then test -e $BUILD_DIR/include/$PKG_NAME.h; fi
    if [[ "$OS_NAME" == "osx" ]]; then test -e $BUILD_DIR/lib/lib$PKG_NAME.dylib; fi
    if [[ "$OS_NAME" == "osx" ]]; then test -e $BUILD_DIR/lib/lib${PKG_NAME}_static.a; fi
    if [[ "$OS_NAME" == "osx" ]]; then test -e $BUILD_DIR/include/$PKG_NAME.h; fi
    bash <(curl -fsSL https://raw.githubusercontent.com/limix/$PKG_NAME/master/install)

    cd $BUILD_DIR
}

(set -x; testit)

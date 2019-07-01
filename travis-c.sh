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
    orig_dir=$(pwd)
    [ -z "$PKG_NAME" ] && PKG_NAME=$(cat NAME)

    bash <(curl -fsSL https://raw.githubusercontent.com/horta/ci/master/check-version.sh)

    mkdir build 2>/dev/null || true
    pushd build
    if [ -z "$TRAVIS_BUILD_DIR" ]
    then
        IPREF=$(mktemp -d)
    else
        IPREF=$TRAVIS_BUILD_DIR/build/install
    fi
    cmake .. -DCMAKE_INSTALL_PREFIX=$IPREF -DCMAKE_BUILD_TYPE=Release
    make && make test && make install

    if [ -z "$TRAVIS_OS_NAME" ]
    then
        OS_NAME=$(echo $(uname) | awk '{print tolower($0)}')
        [ "$OS_NAME" = "darwin" ] && OS_NAME=osx
        echo $OS_NAME
    else
        OS_NAME=$TRAVIS_OS_NAME
    fi

    if [[ "$OS_NAME" == "linux" ]]; then test -e $IPREF/lib/lib$PKG_NAME.so; fi
    if [[ "$OS_NAME" == "linux" ]]; then test -e $IPREF/lib/lib${PKG_NAME}_static.a; fi
    if [[ "$OS_NAME" == "linux" ]]; then test -e $IPREF/include/$PKG_NAME.h; fi
    if [[ "$OS_NAME" == "osx" ]]; then test -e $IPREF/lib/lib$PKG_NAME.dylib; fi
    if [[ "$OS_NAME" == "osx" ]]; then test -e $IPREF/lib/lib${PKG_NAME}_static.a; fi
    if [[ "$OS_NAME" == "osx" ]]; then test -e $IPREF/include/$PKG_NAME.h; fi

    popd && rm -rf build

    cd $orig_dir
}

(set -x; testit)

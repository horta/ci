#!/usr/bin/env bash

set -e

function find_pkg_name {
    python3 -c "from setuptools import find_packages; print(find_packages()[0])"
}

function sdist_test {

    if [ -z "$PKG_NAME" ]
    then
        PKG_NAME=$(find_pkg_name)
    fi

    python3 setup.py sdist
    python3 -m pip install dist/$(ls dist | grep -i -E '\.(gz)$' | head -1)
    cd ~/
    cmd="import sys; import $PKG_NAME; sys.exit(not hasattr($PKG_NAME, 'test'))"
    if python3 -c "$cmd"
    then
        python3 -c "import sys; import $PKG_NAME; sys.exit($PKG_NAME.test())"
    fi
    cd $TRAVIS_BUILD_DIR
}

sdist_test

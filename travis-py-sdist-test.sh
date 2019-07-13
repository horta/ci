#!/usr/bin/env bash

set -e

function find_pkg_name {
    python -c "from setuptools import find_packages; print(find_packages()[0])"
}

function sdist_test {

    if [ -z "$PKG_NAME" ]
    then
        PKG_NAME=$(find_pkg_name)
    fi

    python setup.py sdist
    python -m pip install dist/$(ls dist | grep -i -E '\.(gz)$' | head -1)
    cd ~/
    cmd="import sys; import $PKG_NAME; sys.exit(not hasattr($PKG_NAME, 'test'))"
    if python -c "$cmd"
    then
        python -c "import sys; import $PKG_NAME; sys.exit($PKG_NAME.test())"
    fi
    cd $TRAVIS_BUILD_DIR
}

(set +x; sdist_test)

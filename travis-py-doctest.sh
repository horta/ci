#!/usr/bin/env bash

set -e

function find_pkg_name {
    python3 -c "from setuptools import find_packages; print(find_packages()[0])"
}

function doctest {

    if [ -z "$PKG_NAME" ]
    then
        PKG_NAME=$(find_pkg_name)
    fi

    if [ -d doc ]
    then
        python3 -m pip install -r doc/requirements.txt -q
        (cd doc && make html)
        git clean -xdfq
        python3 -m pip uninstall $PKG_NAME --yes
    fi
}

doctest

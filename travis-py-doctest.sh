#!/usr/bin/env bash

set -e

function find_pkg_name {
    python -c "from setuptools import find_packages; print(find_packages()[0])"
}

function doctest {

    if [ -z "$PKG_NAME" ]
    then
        PKG_NAME=$(find_pkg_name)
    fi

    if [ -d doc ]
    then
        python -m pip install -r doc/requirements.txt -q
        (cd doc && make html)
        git clean -xdfq
        python -m pip uninstall $PKG_NAME --yes
    fi
}

(set +x; doctest)

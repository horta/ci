#!/usr/bin/env bash

set -e

function find_pkg_name
{
    python3 -c "from setuptools import find_packages; print(find_packages()[0])"
}

function doctest
{
    DIR=$1

    if [ -z "$PKG_NAME" ]
    then
        PKG_NAME=$(find_pkg_name)
    fi

    if [ -f $DIR/requirements.txt ]
    then
        python3 -m pip install -r $DIR/requirements.txt
    fi

    (cd $DIR && make html)
    python3 -m pip uninstall $PKG_NAME --yes
    git clean -xdfq
}

if [ $# -eq 0 ]
then
    if [ -d doc ]
    then
        DIR=doc
    elif [ -d docs ]
    then
        DIR=docs
    fi
else
    DIR="$1"
fi

doctest $DIR

#!/usr/bin/env bash

set -e

function find_pkg_name {
    python -c "from setuptools import find_packages; print(find_packages()[0])"
}

function check_import_time {
    PKG_NAME=$1
    cmd="python -c \"import $PKG_NAME\""
    msg=$(timeit "$(echo $cmd)" | grep loop)
    elapsed=$(echo "$msg" | awk -F ' ' '{print $1}')
    unit=$(echo "$msg" | awk -F ' ' '{print $2}')
    if [[ $unit == "s" ]];
    then
        elapsed=$(bc <<< "$elapsed * 1000")
    fi
    elapsed=${elapsed%.*}

    echo "Importing time: $elapsed milliseconds"
    if [[ $elapsed -ge 1500 ]];
    then
        (>&2 echo "Too slow to import $PKG_NAME: more than a second.")
        (>&2 echo "Please, fix it as it is taking $elapsed ms.")
        exit 1
    fi
}

function install_test {
    if [ -z "$PKG_NAME" ]
    then
        PKG_NAME=$(find_pkg_name)
    fi

    python -m pip install -q .
    git clean -xdfq
    cd ~/

    check_import_time $PKG_NAME

    python -m pip uninstall $PKG_NAME --yes
    cd $TRAVIS_BUILD_DIR
    git clean -xdfq
}

install_test

#!/usr/bin/env bash

set -e

function find_pkg_name
{
    python3 -c "from setuptools import find_packages; print(find_packages()[0])"
}
[ -z "$PKG_NAME" ] && PKG_NAME=$(find_pkg_name)

function check_import_time
{
    cmd="python3 -c \"import $PKG_NAME\""
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
        (>&2 echo "🔥 Too slow to import $PKG_NAME: more than a second.")
        (>&2 echo "🔥 Please, fix it as it is taking $elapsed ms.")
        exit 1
    else
        echo "😊 Importing time check was a success."
    fi
}

function install_test
{
    python3 -m pip install .
    git clean -xdfq

    (cd ~/ && check_import_time $PKG_NAME)

    python3 -m pip uninstall $PKG_NAME --yes
    git clean -xdfq
    
}

python3 pip install -U shell-timeit
install_test

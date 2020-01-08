#!/usr/bin/env bash

function install_deps
{
    
    if ! python3 -m pip install -U pytest
    then
        (>&2 echo "🔥 We have failed to install `pytest`.")
        exit 1
    fi
}

function devtest
{
    if ! python3 setup.py test
    then
        (>&2 echo "🔥 Development test has failed.")
        exit 1
    fi
    git clean -xdfq
}

install_deps
devtest
echo "😊 Development test was a success."

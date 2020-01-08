#!/usr/bin/env bash

set -e

NUMPY="no"
SCIPY="no"

while :; do
    case $1 in
        --numpy) NUMPY="yes"            
        ;;
        --scipy) SCIPY="yes"            
        ;;
        *) break
    esac
    shift
done

function has_conda
{
    type conda >/dev/null 2>&1
}

function try_conda_install
{
    if has_conda;
    then
        conda install $1 --yes
    else
        python3 -m pip install $1 -U
    fi
}

function install_deps
{
    python3 -m pip install -U setuptools wheel pip

    [ $NUMPY = "yes" ] && try_conda_install numpy
    [ $SCIPY = "yes" ] && try_conda_install scipy
}

install_deps

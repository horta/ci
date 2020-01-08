#!/usr/bin/env bash

set -e

function has_conda() {
    type conda >/dev/null 2>&1
}

function install_deps() {
    # python3 -m pip install -U pytest-pycodestyle
    python3 -m pip install -U setuptools wheel pip
    # flake8 rstcheck rstcheck shell-timeit
    # python3 -m pip install -U pygments docutils sphinx

    # Try to install conda-provided numpy and scipy first as they
    # are faster because of the MKL library.
    if has_conda;
    then
        conda install numpy scipy --yes
    else
        python3 -m pip install numpy scipy -U
    fi
}

install_deps

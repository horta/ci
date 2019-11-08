#!/usr/bin/env bash

set -e

function has_conda() {
    type conda >/dev/null 2>&1
}

function install_deps() {
    python -m pip install -U setuptools pip pytest pytest-pycodestyle
    python -m pip install -U flake8 rstcheck pygments docutils
    python -m pip install -U sphinx
    python -m pip install -U rstcheck
    python -m pip install -U shell-timeit

    # Try to install conda-provided numpy and scipy first as they
    # are faster because of the MKL library.
    if has_conda;
    then
        conda install numpy scipy --yes
    else
        python -m pip install numpy scipy -U
    fi
}

install_deps

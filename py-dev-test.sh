#!/usr/bin/env bash

set -e

function install_deps() {
    python3 -m pip install -U pytest
}

function devtest {
    python3 setup.py test
    git clean -xdfq
}

install_deps
devtest

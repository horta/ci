#!/usr/bin/env bash

set -e

function devtest {
    python3 setup.py test
    git clean -xdfq
}

devtest

#!/usr/bin/env bash

set -e

function devtest {
    python setup.py test
    git clean -xdfq
}

(set +x; devtest)

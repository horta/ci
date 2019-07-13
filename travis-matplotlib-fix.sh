#!/usr/bin/env bash

set -e

function matplotlib_backend_fix() {
    mkdir -p ~/.config/matplotlib
    if ! test ~/.config/matplotlib/matplotlibrc;
    then
        echo "backend : Agg" > ~/.config/matplotlib/matplotlibrc
    fi
}

matplotlib_backend_fix

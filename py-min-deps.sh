#!/usr/bin/env bash

NUMPY="no"
SCIPY="no"
PANDAS="no"

while :; do
    case $1 in
        --numpy) NUMPY="yes"
        ;;
        --scipy) SCIPY="yes"
        ;;
        --pandas) PANDAS="yes"
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
    if [ $? -ne 0 ]
    then
        (>&2 echo "🔥 We have failed to install `$1`.")
        exit 1
    fi
}

function install_deps
{
    python3 -m pip install -U setuptools wheel pip

    if [ $NUMPY = "yes" ]; then try_conda_install numpy; fi
    if [ $SCIPY = "yes" ]; then try_conda_install scipy; fi
    if [ $PANDAS = "yes" ]; then try_conda_install pandas; fi
}

install_deps
echo "😊 Dependencies installation was a success."

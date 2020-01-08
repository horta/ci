#!/usr/bin/env bash

function find_pkg_name
{
    python3 -c "from setuptools import find_packages; print(find_packages()[0])"
}
[ -z "$PKG_NAME" ] && PKG_NAME=$(find_pkg_name)

function sdist_test
{
    cmd="import sys; import $PKG_NAME; sys.exit(not hasattr($PKG_NAME, 'test'))"
    if python3 -c "$cmd"
    then
        if ! python3 -c "import sys; import $PKG_NAME; sys.exit($PKG_NAME.test())"
        then
            (>&2 echo "🔥 Source distribution test has failed.")
            exit 1
        fi
    fi
}

python3 setup.py sdist
python3 -m pip install dist/$(ls dist | grep -i -E '\.(gz)$' | head -1)

(cd ~/ && sdist_test)
git clean -xdfq

echo "😊 Source distribution test was a success."

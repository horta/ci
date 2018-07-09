#!/bin/bash

set -e

python -m pip install -U setuptools pip pytest pytest-pycodestyle -q
python -m pip install -U numpy -q --only-binary :all:
python setup.py test && git clean -xdf
python -m pip install . && git clean -xdf
cd ..
python -c "import sys; import $PKG_NAME; sys.exit($PKG_NAME.test())"
python -m pip uninstall $PKG_NAME --yes
cd $TRAVIS_BUILD_DIR && git clean -xdf
python -m pip install -r requirements.txt -q
cd doc && make html && cd $TRAVIS_BUILD_DIR
git clean -xdf
python setup.py sdist
python -m pip install dist/$(ls dist | grep -i -E '\.(gz)$' | head -1)
cd ..
python -c "import sys; import $PKG_NAME; sys.exit($PKG_NAME.test())"
cd $TRAVIS_BUILD_DIR

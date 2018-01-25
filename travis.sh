#!/bin/bash

set -e

pip install -U setuptools pip pypandoc -q
python setup.py test && git clean -xdf
pip install . && git clean -xdf
cd ..
python -c "import sys; import $PKG_NAME; sys.exit($PKG_NAME.test())"
pip uninstall $PKG_NAME --yes
cd $TRAVIS_BUILD_DIR && git clean -xdf
pip install -r requirements.txt -q
cd doc && make html && cd $TRAVIS_BUILD_DIR
git clean -xdf
python setup.py sdist
pip install dist/$(ls dist | grep -i -E '\.(gz)$' | head -1)
cd ..
python -c "import sys; import $PKG_NAME; sys.exit($PKG_NAME.test())"
cd $TRAVIS_BUILD_DIR

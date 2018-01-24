#!/bin/bash

pip install -U setuptools pip pypandoc
python setup.py test && git clean -xdf
pip install . && git clean -xdf
cd ..
python -c "import sys; import $PKG_NAME; sys.exit($PKG_NAME.test())"
pip uninstall $PKG_NAME --yes
cd $TRAVIS_BUILD_DIR && git clean -xdf
pip install -r requirements.txt
cd doc && make html && cd ..
git clean -xdf
python setup.py sdist

@echo off

set PATH=%PYTHON%;%PYTHON%\\Scripts;%PATH%
pip install -U setuptools pip pypandoc
python setup.py build_ext --inplace
python setup.py test
pip install .
cd ..
python -c "import sys; import %PKG_NAME%; sys.exit(%PKG_NAME%.test())"
pip uninstall %PKG_NAME% --yes
cd %APPVEYOR_BUILD_FOLDER%
pip install -r requirements.txt
cd doc && make html && cd ..
python setup.py sdist

@echo on

@echo off

set PATH=%PYTHON%;%PYTHON%\\Scripts;%PATH%
pip install -U setuptools pip pypandoc

python setup.py build_ext --inplace
if errorlevel 1 exit 1

python setup.py test
if errorlevel 1 exit 1

pip install .
cd ..

python -c "import sys; import %PKG_NAME%; sys.exit(%PKG_NAME%.test())"
if errorlevel 1 exit 1

pip uninstall %PKG_NAME% --yes
cd %APPVEYOR_BUILD_FOLDER%
pip install -r requirements.txt

cd doc && make html
if errorlevel 1 exit 1

cd .. && python setup.py sdist

@echo on

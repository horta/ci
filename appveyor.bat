@echo off

echo %PATH%
python -m pip install -U setuptools pip pytest pytest-runner pytest-pycodestyle cffi numpy

python setup.py test
if errorlevel 1 exit 1

pip install .
cd ..

python -c "import sys; import %PKG_NAME%; sys.exit(%PKG_NAME%.test())"
if errorlevel 1 exit 1

pip uninstall %PKG_NAME% --yes
cd %APPVEYOR_BUILD_FOLDER%
pip install -r requirements.txt

if exist doc\make.bat (
  cd doc && make.bat html
  if errorlevel 1 exit 1
  cd %APPVEYOR_BUILD_FOLDER%
)

python setup.py sdist

@echo on

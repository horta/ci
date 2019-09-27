@echo off
setlocal enableextensions enabledelayedexpansion

set VERSION="0.0.1"
echo Appveyor continuous integration script (%VERSION%)
echo ----------------------------------------------

echo
set PATH=%PYTHON%;%PYTHON%\Scripts;%PATH%

echo PATH=%PATH%
echo PYTHON=%PYTHON%

md %USERPROFILE%\.matplotlib
if exist %USERPROFILE%\.matplotlib\matplotlibrc (
    echo File %USERPROFILE%\.matplotlib\matplotlibrc exists.
) else (
    type NUL > %USERPROFILE%\.matplotlib\matplotlibrc
    echo backend : Agg >>  %USERPROFILE%\.matplotlib\matplotlibrc
)

python -m pip install -U cffi numpy pip pytest pytest-pycodestyle setuptools -q

python setup.py test
if errorlevel 1 exit 1

python -m pip install .
cd ..

python -c "import sys; import %PKG_NAME%; sys.exit(not hasattr(%PKG_NAME%, 'test'))"
if %ERRORLEVEL% EQU 0 (
  python -c "import sys; import %PKG_NAME%; sys.exit(%PKG_NAME%.test())"
)
if errorlevel 1 exit 1

python -m pip uninstall %PKG_NAME% --yes
cd %APPVEYOR_BUILD_FOLDER%

if exist requirements.txt (
  python -m pip install -r requirements.txt
)
if exist doc\requirements.txt (
  python -m pip install -r doc\requirements.txt
)

if exist doc\make.bat (
  cd doc && make.bat html
  if errorlevel 1 exit 1
  cd %APPVEYOR_BUILD_FOLDER%
)

if exist docs\make.bat (
  cd docs && make.bat html
  if errorlevel 1 exit 1
  cd %APPVEYOR_BUILD_FOLDER%
)

python setup.py sdist

@echo on

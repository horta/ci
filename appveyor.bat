@echo off

set PATH=%PYTHON%;%PYTHON%\Scripts;%PATH%

echo %PATH%
echo %PYTHON%

python -m pip install -U cffi numpy pip pytest pytest-pycodestyle setuptools -q

python setup.py test
if errorlevel 1 exit 1

python -m pip install .
cd ..

python -c "import sys; import %PKG_NAME%; sys.exit(%PKG_NAME%.test())"
if errorlevel 1 exit 1

python -m pip uninstall %PKG_NAME% --yes
cd %APPVEYOR_BUILD_FOLDER%
python -m pip install -r requirements.txt

if exist doc\make.bat (
  cd doc && make.bat html
  if errorlevel 1 exit 1
  cd %APPVEYOR_BUILD_FOLDER%
)

python setup.py sdist

@echo on

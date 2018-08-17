@echo off

echo %PATH%
echo %PYTHON%
%PYTHON% -m pip install -U cffi numpy pip pytest pytest-pycodestyle setuptools -q

%PYTHON% setup.py test
if errorlevel 1 exit 1

%PYTHON% -m pip install .
cd ..

%PYTHON% -c "import sys; import %PKG_NAME%; sys.exit(%PKG_NAME%.test())"
if errorlevel 1 exit 1

%PYTHON% -m pip uninstall %PKG_NAME% --yes
cd %APPVEYOR_BUILD_FOLDER%
%PYTHON% -m pip install -r requirements.txt

if exist doc\make.bat (
  cd doc && make.bat html
  if errorlevel 1 exit 1
  cd %APPVEYOR_BUILD_FOLDER%
)

%PYTHON% setup.py sdist

@echo on

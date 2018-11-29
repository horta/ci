#!/bin/bash

set -e

function matplotlib_backend_fix() {
    mkdir -p ~/.config/matplotlib
    if ! test ~/.config/matplotlib/matplotlibrc;
    then
        echo "backend : Agg" > ~/.config/matplotlib/matplotlibrc
    fi
}

function check_style() {
    if ! flake8;
    then
        (>&2 echo "Please, check your code using flake8.")
        exit 1
    fi

    if ! rstcheck -r .;
    then
        (>&2 echo "Please, check your code using rstcheck.")
        exit 1
    fi

    if msg=$(grep --include=\*.{py,rst} -Rn -P "\t");
    then
        (>&2 echo "Please, remove tab character from the following files.")
        (>&2 echo "$msg")
        exit 1
    fi
}

MAJOR=$(python -c 'import platform; print(platform.python_version())' | awk -F '.' '{print $1}')

matplotlib_backend_fix
check_style

python -m pip install -U setuptools pip pytest pytest-pycodestyle -q
python -m pip install -U numpy flake8 rstcheck pygments -q
python -m pip install -U shell-timeit -q


if [[ $MAJOR -gt 2 ]];
then
    python -m pip install -U black -q
    git clean -xdf

    # Make sure the code has been formatted.
    find . -type f -name "*.py" -exec cksum "{}" \; | sort > checksum0.txt
    find . -type f -name "*.py" -exec black --quiet --fast {} \;
    find . -type f -name "*.py" -exec cksum "{}" \; | sort > checksum1.txt
    if ! diff checksum0.txt checksum1.txt >/dev/null;
    then
        (>&2 echo "Please, apply the black Python code formatter on the following files:")
        diff checksum0.txt checksum1.txt | sed '1d; n; d' | awk -F ' ' '{print $4}' | uniq
        rm checksum0.txt
        rm checksum1.txt
        exit 1
    else
        rm checksum0.txt
        rm checksum1.txt
    fi
fi

python setup.py test && git clean -xdf
python -m pip install -q . && git clean -xdf
cd ~/

cmd="python -c \"import $PKG_NAME\""
msg=$(timeit "$(echo $cmd)" | grep loop)
elapsed=$(echo "$msg" | awk -F ' ' '{print $1}')
unit=$(echo "$msg" | awk -F ' ' '{print $2}')
if [[ $unit == "s" ]];
then
    elapsed=$(bc <<< "$elapsed * 1000")
fi
elapsed=${elapsed%.*}

echo "Importing time: $elapsed milliseconds"
if [[ $elapsed -ge 1000 ]];
then
    (>&2 echo "Too slow to import $PKG_NAME: more than a second.")
    (>&2 echo "Please, fix it as it is taking $elapsed ms.")
fi

python -c "import sys; import $PKG_NAME; sys.exit($PKG_NAME.test())"
python -m pip uninstall $PKG_NAME --yes
cd $TRAVIS_BUILD_DIR && git clean -xdf
python -m pip install -r requirements.txt -q
python -m pip install . && git clean -xdf
[ -d doc ] && cd doc && make html && cd $TRAVIS_BUILD_DIR
git clean -xdf
python -m pip uninstall $PKG_NAME --yes
python setup.py sdist
python -m pip install dist/$(ls dist | grep -i -E '\.(gz)$' | head -1)
cd ~/
python -c "import sys; import $PKG_NAME; sys.exit($PKG_NAME.test())"
cd $TRAVIS_BUILD_DIR



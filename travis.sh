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
    flake8 --version
    if ! flake8;
    then
        (>&2 echo "Please, check your code using flake8.")
        exit 1
    fi

    rstcheck --version
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

function check_black_format() {
    if [[ $MAJOR -gt 2 ]];
    then
        python -m pip install -U black -q
        git clean -xdf

        echo "Ponto 1"
        # Make sure the code has been formatted.
        find . -type f -name "*.py" -exec cksum "{}" \; | sort > checksum0.txt
        find . -type f -name "*.py" -exec black --quiet --fast {} \;
        find . -type f -name "*.py" -exec cksum "{}" \; | sort > checksum1.txt
        echo "Ponto 2"
        cat checksum0.txt
        cat checksum1.txt
        echo "Ponto 3"
        if ! diff checksum0.txt checksum1.txt;
        then
            err="Please, apply the black Python code formatter"
            (>&2 echo "$err on the following files:")
            echo "Ponto 4"
            msg=$(diff checksum0.txt checksum1.txt | sed '1d; n; d')
            echo "Ponto 5"
            echo $(awk -F ' ' '{print $4}' | uniq)
            echo "Ponto 6"
            rm checksum0.txt
            rm checksum1.txt
            exit 1
        else
            rm checksum0.txt
            rm checksum1.txt
        fi
    fi
}

function has_mkl() {
    cmd="python -c \"import numpy as np;"
    cmd="$cmd print(len(np.__config__.blas_mkl_info) > 0)\""
    has=$(eval $cmd)
    test $has = True
}

function has_conda() {
    type conda >/dev/null 2>&1
}

install_deps() {
    python -m pip install -U setuptools pip pytest pytest-pycodestyle -q
    python -m pip install -U flake8 rstcheck pygments docutils -q
    python -m pip install -U shell-timeit -q

    if has_conda;
    then
        conda install numpy scipy --yes -q
    else
        pip install intel-numpy intel-scipy -q -U
    fi
}

cmd="python -c 'import platform; print(platform.python_version())'"
cmd="$cmd | awk -F '.' '{print \$1}'"
MAJOR=$(eval $cmd)

matplotlib_backend_fix
install_deps
check_style
check_black_format

python setup.py test && git clean -xdfq
python -m pip install -q . && git clean -xdfq
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
cd $TRAVIS_BUILD_DIR && git clean -xdfq
python -m pip install -r requirements.txt -q
python -m pip install . && git clean -xdfq
[ -d doc ] && cd doc && make html && cd $TRAVIS_BUILD_DIR
git clean -xdfq
python -m pip uninstall $PKG_NAME --yes
python setup.py sdist
python -m pip install dist/$(ls dist | grep -i -E '\.(gz)$' | head -1)
cd ~/
python -c "import sys; import $PKG_NAME; sys.exit($PKG_NAME.test())"
cd $TRAVIS_BUILD_DIR



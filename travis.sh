#!/bin/bash

set -e

MAJOR=$(python -c 'import platform; print(platform.python_version())' | awk -F '.' '{print $1}')

mkdir -p ~/.config/matplotlib
if ! test ~/.config/matplotlib/matplotlibrc;
then
    echo "backend : Agg" > ~/.config/matplotlib/matplotlibrc
fi

python -m pip install -U setuptools pip pytest pytest-pycodestyle -q
python -m pip install -U numpy flake8 doc8 pygments -q
# python -m pip install -U shell-timeit

# cmd="python -c \"import $PKG_NAME\""
# msg=$(timeit "$(echo $cmd)" | grep loop)
# elapsed=$(echo "$msg" | awk -F ' ' '{print $1}')
# unit=$(echo "$msg" | awk -F ' ' '{print $2}')
# if [[ $unit == "s" ]];
# then
#     elapsed=$(bc <<< "$elapsed * 1000")
# fi
# elapsed=${elapsed%.*}

# echo "Importing time: $elapsed milliseconds"
# if [[ $elapsed -ge 1000 ]];
# then
#     (>&2 echo "Too slow to import $PKG_NAME: more than a second.")
#     (>&2 echo "Please, fix it as it is taking $elapsed ms.")
# fi

if ! flake8;
then
    (>&2 echo "Please, check your code using flake8.")
    exit 1
fi

if ! doc8;
then
    (>&2 echo "Please, check your code using doc8.")
    exit 1
fi

if msg=$(grep --include=\*.{py,rst} -rnw . -e "\t");
then
    (>&2 echo "Please, remove tab character from the following files.")
    (>&2 echo "$msg")
    exit 1
fi

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
python -m pip install -q --process-dependency-links . && git clean -xdf
cd ~/
python -c "import sys; import $PKG_NAME; sys.exit($PKG_NAME.test())"
python -m pip uninstall $PKG_NAME --yes
cd $TRAVIS_BUILD_DIR && git clean -xdf
python -m pip install -r requirements.txt -q
python -m pip install --process-dependency-links . && git clean -xdf
[ -d doc ] && cd doc && make html && cd $TRAVIS_BUILD_DIR
git clean -xdf
python -m pip uninstall $PKG_NAME --yes
python setup.py sdist
python -m pip install --process-dependency-links dist/$(ls dist | grep -i -E '\.(gz)$' | head -1)
cd ~/
python -c "import sys; import $PKG_NAME; sys.exit($PKG_NAME.test())"
cd $TRAVIS_BUILD_DIR

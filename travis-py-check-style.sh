#!/usr/bin/env bash

set -e

function check_style() {
    echo "flake8:" $(flake8 --version)
    if ! flake8;
    then
        (>&2 echo "🔥 Please, check your code using flake8. 🔥")
        exit 1
    fi

    if [ "${TRAVIS_OS_NAME}" == "linux" ];
    then
        rstcheck --version
        if ! rstcheck -h | grep 'Sphinx is enabled';
        then
            (>&2 echo "🔥 Sphinx is not enabled. Please, install it first.")
            exit 1
        fi
        if ! rstcheck -r .;
        then
            (>&2 echo "🔥 Please, check your code using rstcheck.")
            exit 1
        fi
    fi

    if msg=$(grep --include=\*.{py,rst} -Rn -P "\t" 2> /dev/null);
    then
        (>&2 echo "🔥 Please, remove tab character from the following files.")
        (>&2 echo "$msg")
        exit 1
    fi

    echo "😊 Style check was a success."
}

function check_black_format() {
    python3 -m pip install -U black -q
    git clean -xdf

    # Make sure the code has been formatted.
    find . -type f -name "*.py" -exec cksum "{}" \; | sort > checksum0.txt
    find . -type f -name "*.py" -exec black --quiet --fast {} \;
    find . -type f -name "*.py" -exec cksum "{}" \; | sort > checksum1.txt
    cat checksum0.txt
    cat checksum1.txt
    if ! diff checksum0.txt checksum1.txt;
    then
        err="🔥 Please, apply the black Python code formatter"
        (>&2 echo "$err on the following files:")
        msg=$(diff checksum0.txt checksum1.txt | sed '1d; n; d')
        echo $(echo $msg | awk -F ' ' '{print $4}' | uniq)
        rm checksum0.txt
        rm checksum1.txt
        exit 1
    else
        rm checksum0.txt
        rm checksum1.txt
    fi
}

check_style
check_black_format

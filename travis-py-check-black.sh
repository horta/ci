#!/usr/bin/env bash

set -e

function check_black_format() {
    python -m pip install -U black -q
    git clean -xdf

    # Make sure the code has been formatted.
    find . -type f -name "*.py" -exec cksum "{}" \; | sort > checksum0.txt
    find . -type f -name "*.py" -exec black --quiet --fast {} \;
    find . -type f -name "*.py" -exec cksum "{}" \; | sort > checksum1.txt
    cat checksum0.txt
    cat checksum1.txt
    if ! diff checksum0.txt checksum1.txt;
    then
        err="Please, apply the black Python code formatter"
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

(set +x; check_black_format)
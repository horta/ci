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


(set +x; check_style)

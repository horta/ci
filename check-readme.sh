#!/usr/bin/env bash

set -e

function check_broken_links
{
    [ ! -f README.md ] && return 0

    if type gem && gem install awesome_bot
    then
        if ! awesome_bot README.md --allow-dupe --allow-redirect --skip-save-results
        then
            (>&2 echo "🔥 README check failed.")
            exit 1
        fi
    fi
}

check_broken_links
echo "😊 README check was a success."

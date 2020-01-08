#!/usr/bin/env bash

set -e

function check_broken_links
{
    if type gem && gem install awesome_bot
    then
        if [ -f README.md ]
        then
            awesome_bot README.md --allow-dupe --allow-redirect --skip-save-results
            [ $? -ne 0 ] && exit 1
        fi
    fi
}

check_broken_links

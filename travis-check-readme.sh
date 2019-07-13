#!/usr/bin/env bash

set -e

function check_broken_links() {

    if type gem && gem install awesome_bot
    then
        if [ -f README.md ]
        then
            awesome_bot README.md --allow-dupe --allow-redirect --skip-save-results
            if [ $? -ne 0 ]
            then
                exit 1
            fi
        fi
    fi
}

(set +x; check_broken_links)

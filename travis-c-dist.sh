#!/bin/bash

set -e


mkdir dist && pushd dist && cmake .. -DCMAKE_BUILD_TYPE=Release && popd
mv dist $PRJ_NAME-`cat VERSION`
tar czf $PRJ_NAME-`cat VERSION`.tar.gz $PRJ_NAME-`cat VERSION`
rm -rf dist

#!/usr/bin/env bash

function trim
{
    trimmed=$([[ "$1" =~ [[:space:]]*([^[:space:]]|[^[:space:]].*[^[:space:]])[[:space:]]* ]]; echo -n "${BASH_REMATCH[1]}")
    echo $trimmed
}

PRJ_NAME=$(trim $(cat NAME))
VERSION=$(trim $(cat VERSION))
HEADER=include/$PRJ_NAME.h
PRJ_NAME_UP=$(echo $PRJ_NAME | awk '{print toupper($0)}')

if ! [ -a ${HEADER} ]; then
    echo "File ${HEADER} does not exist."
    exit 1
fi

SVER=$(cat ${HEADER} | grep "${PRJ_NAME_UP}_VERSION " | cut -d' ' -f3 | tr -d '"')

if [[ $VERSION != $SVER ]];
then
    echo "$VERSION and $SVER differ."
    echo "Please, compare $HEADER with VERSION file."
    exit 1
fi

VERSION_MAJOR=$(echo $VERSION | cut -d'.' -f1)
VERSION_MINOR=$(echo $VERSION | cut -d'.' -f2)
VERSION_PATCH=$(echo $VERSION | cut -d'.' -f3)

MAJOR=$(cat ${HEADER} | grep "${PRJ_NAME_UP}_VERSION_MAJOR " | cut -d' ' -f3 | tr -d ' ')
MINOR=$(cat ${HEADER} | grep "${PRJ_NAME_UP}_VERSION_MINOR " | cut -d' ' -f3 | tr -d ' ')
PATCH=$(cat ${HEADER} | grep "${PRJ_NAME_UP}_VERSION_PATCH " | cut -d' ' -f3 | tr -d ' ')

if [ $VERSION_MAJOR -ne $MAJOR ] || [ $VERSION_MINOR -ne $MINOR ] || [ $VERSION_PATCH -ne $PATCH ];
then
    echo -n "ERROR: versions $VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH and "
    echo "$MAJOR.$MINOR.$PATCH differ."
    echo "Please, compare the \`$HEADER\` and \`VERSION\` files."
    exit 1
else
    echo -e "\e[32mSuccess: versions match.\e[39m"
fi

exit 0

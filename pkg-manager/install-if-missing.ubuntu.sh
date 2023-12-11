#!/bin/bash

set -e

#APP_NAME=$1
#REMOTE_SOURCE_LIST=$2
#REPO_KEY=$3

if [ -z "$APP_NAME" ]; then
    echo "APP_NAME is not set"
    exit 1
fi

if [ ! -z "$REMOTE_SOURCE_LIST" ]; then
    if [ -z "$REPO_KEY" ]; then
        echo "REPO_KEY for REMOTE_SOURCE_LIST is not set"
        exit 1
    fi

    ARCH=$(dpkg-architecture -q DEB_BUILD_ARCH)
    wget -q -O - $REPO_KEY | sudo apt-key add -
    echo "deb [arch=amd64] $REMOTE_SOURCE_LIST stable main" | sudo tee /etc/apt/sources.list.d/$APP_NAME.list
    sudo apt update -y
fi

if brew list $APP_NAME &>/dev/null; then
    echo "$APP_NAME is already installed"
else
    sudo apt install -y $APP_NAME
fi

#!/bin/bash

set -e

if [ -z "$APP_NAME" ]; then
    echo "APP_NAME is not set"
    exit 1
fi

if dpkg -s "$APP_NAME" &>/dev/null; then
    echo "$APP_NAME is already installed"
    exit 0
fi

if [ -n "$REMOTE_SOURCE_LIST" ]; then
    if [ -z "$REPO_KEY" ]; then
        echo "REPO_KEY for REMOTE_SOURCE_LIST is not set"
        exit 1
    fi

    wget -q -O - "$REPO_KEY" | sudo apt-key add -
    echo "deb [arch=amd64] $REMOTE_SOURCE_LIST stable main" | sudo tee "/etc/apt/sources.list.d/$APP_NAME.list"
    sudo apt update -y
fi

sudo apt install -y "$APP_NAME"

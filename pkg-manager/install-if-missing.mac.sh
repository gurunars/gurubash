#!/bin/bash

if [ -z "$APP_NAME" ]; then
    echo "APP_NAME env is not set"
    exit 1
fi

if /opt/homebrew/bin/brew list $APP_NAME &>/dev/null; then
    echo "$APP_NAME is already installed"
else
    /opt/homebrew/bin/brew install $APP_NAME
fi

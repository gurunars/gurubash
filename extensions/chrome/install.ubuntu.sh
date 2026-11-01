#!/bin/bash

set -e

# Chrome's package adds its own apt source for this repo unless this file exists;
# two sources with different signed-by values make apt refuse to run.
if ! dpkg -s google-chrome-stable &>/dev/null; then
    sudo touch /etc/default/google-chrome
fi

APP_NAME=google-chrome-stable \
REMOTE_SOURCE_LIST=https://dl.google.com/linux/chrome/deb/ \
REPO_KEY=https://dl.google.com/linux/linux_signing_key.pub \
/bin/bash "$INSTALL"

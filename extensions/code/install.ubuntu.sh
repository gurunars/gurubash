#!/bin/bash

set -e

# Code's package offers to add its own apt source for this repo; two sources with
# different signed-by values make apt refuse to run.
if ! dpkg -s code &>/dev/null; then
    echo "code code/add-microsoft-repo boolean false" | sudo debconf-set-selections
fi

APP_NAME=code \
REMOTE_SOURCE_LIST=https://packages.microsoft.com/repos/code \
REPO_KEY=https://packages.microsoft.com/keys/microsoft.asc \
/bin/bash "$INSTALL"

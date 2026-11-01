#!/bin/bash

set -e

# `which brew` misses it until core/pkg-manager/loader.mac has put it on PATH.
if [ -x /opt/homebrew/bin/brew ]; then
    echo "Brew is already installed"
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

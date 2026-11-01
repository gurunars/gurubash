#!/bin/bash

set -e

if [ -e "${HOME}/.dotnet/dotnet" ]; then
    echo "dotnet is already installed"
else
    curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --version latest
fi

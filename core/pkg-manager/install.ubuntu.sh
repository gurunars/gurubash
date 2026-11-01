#!/bin/bash

set -e

# Upgrading is `up`'s job, not the installer's.
if dpkg -s software-properties-common apt-transport-https wget curl &>/dev/null; then
    echo "Base packages are already installed"
else
    sudo apt update -y
    sudo apt install -y software-properties-common apt-transport-https wget curl
fi
sudo mkdir -p /etc/apt/sources.list.d

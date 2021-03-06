#!/bin/bash

wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -

echo "deb [arch=amd64] http://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

sudo apt update -y

sudo apt install -y code

VS_PATH=${HOME}/.config/Code/User

mkdir -p ${VS_PATH}

ln -f -s ~/.gurubash/code/keybindings.json ${VS_PATH}/keybindings.json
ln -f -s ~/.gurubash/code/settings.json ${VS_PATH}/settings.json

# extensions

function ext {
    code --install-extension $1
}

# Docker
ext ms-azuretools.vscode-docker
# Eslint
ext dbaeumer.vscode-eslint
# Typescript
ext ms-vscode.vscode-typescript-next
# For multi-keybindings
ext ryuta46.multi-command
# Pyright
ext ms-pyright.pyright
# Python
ext ms-python.python
# React native
ext msjsdiag.vscode-react-native
# PDF preview
ext tomoki1207.pdf
# Markdown support
ext docsmsft.docs-markdown
# Vue
ext octref.vetur
# Jest
ext orta.vscode-jest
# Markdown lint
ext davidanson.vscode-markdownlint
# Style lint
ext stylelint.vscode-stylelint

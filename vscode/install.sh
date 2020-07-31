#!/bin/bash

echo "deb [arch=amd64] http://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

sudo apt install code

VS_PATH=${HOME}/.config/Code/User

mkdir -p ${VS_PATH}

ln -f -s ~/.gurubash/vscode/keybindings.json ${VS_PATH}/keybindings.json
ln -f -s ~/.gurubash/vscode/settings.json ${VS_PATH}/settings.json

# extensions

function ext {
    code --install-extension $1
}

ext ms-azuretools.vscode-docker
ext dbaeumer.vscode-eslint
ext ms-vscode.vscode-typescript-next
ext ryuta46.multi-command
ext ms-pyright.pyright
ext ms-python.python
ext msjsdiag.vscode-react-native
ext tomoki1207.pdf
ext shd101wyy.markdown-preview-enhanced
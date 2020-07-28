#!/bin/bash

VS_PATH=${HOME}/.config/Code/User

mkdir -p ${VS_PATH}

ln -f -s ~/.gurubash/vscode/keybindings.json ${VS_PATH}/keybindings.json
ln -f -s ~/.gurubash/vscode/settings.json ${VS_PATH}/settings.json
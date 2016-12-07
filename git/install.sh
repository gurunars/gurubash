#!/bin/bash
bash ~/.gurubash/personal/install.sh

cp ~/.gurubash/git/gitconfig ~/.personal/gitconfig
ln -s ~/.personal/gitconfig ~/.gitconfig

. ~/.gurubash/personal/loader

git config --global user.name "$NAME"
git config --global user.email "$EMAIL"

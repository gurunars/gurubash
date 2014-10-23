#!/bin/bash
cp ~/.gurubash/vim/gitconfig ~/.gitconfig
. ~/.gurubash/cridentials/loader
git config --global user.name "$NAME"
git config --global user.email "$EMAIL"
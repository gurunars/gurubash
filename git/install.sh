#!/bin/bash
cp ~/.gurubash/git/gitconfig ~/.gitconfig
. ~/.gurubash/cridentials/loader
git config --global user.name "$NAME"
git config --global user.email "$EMAIL"

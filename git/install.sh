#!/bin/bash

sudo apt install git

ln -f -s ~/.gurubash/git/gitconfig ~/.gitconfig

. ~/.gurubash/personal/loader

git config --global user.name "${NAME}"
git config --global user.email "${EMAIL}"

#!/bin/bash

sudo apt install git

ln -f -s ~/.gurubash/git/gitconfig ~/.gitconfig

. ~/.gurubash/personal/loader

mkdir ~/repo
git config -f ~/repo/gitconfig user.name "${NAME}"
git config -f ~/repo/gitconfig user.email "${EMAIL}"

mkdir ~/work
git config -f ~/work/gitconfig user.name "${NAME}"
git config -f ~/work/gitconfig user.email "${EMAIL}"

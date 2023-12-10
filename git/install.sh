#!/bin/bash

ln -f -s ${ROOT}/git/gitconfig $HOME/.gitconfig

. ${ROOT}/personal/loader

mkdir -p $HOME/repo
git config -f $HOME/repo/gitconfig user.name "${NAME}"
git config -f $HOME/repo/gitconfig user.email "${EMAIL}"

mkdir -p $HOME/work
git config -f $HOME/work/gitconfig user.name "${NAME}"
git config -f $HOME/work/gitconfig user.email "${EMAIL}"

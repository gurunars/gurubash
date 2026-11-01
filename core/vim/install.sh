#!/bin/bash

set -e

APP_NAME=vim /bin/bash "$INSTALL"

ln -f -s "${GURUBASH}/core/vim/vimrc" "${HOME}/.vimrc"

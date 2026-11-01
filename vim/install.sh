#!/bin/bash

set -e

APP_NAME=vim "$INSTALL"

ln -f -s "${GURUBASH}/vim/vimrc" "${HOME}/.vimrc"

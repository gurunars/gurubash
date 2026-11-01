#!/bin/bash

set -e

APP_NAME=git /bin/bash "$INSTALL"

ln -f -s "${GURUBASH}/core/git/gitconfig" "${HOME}/.gitconfig"

. "${GURUBASH}/core/personal/loader"

mkdir -p "${HOME}/repo"
git config -f "${HOME}/repo/gitconfig" user.name "${NAME}"
git config -f "${HOME}/repo/gitconfig" user.email "${EMAIL}"

mkdir -p "${HOME}/work"
git config -f "${HOME}/work/gitconfig" user.name "${NAME}"
git config -f "${HOME}/work/gitconfig" user.email "${EMAIL}"

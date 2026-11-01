#!/bin/bash

set -e

echo "export GURUBASH=${GURUBASH}" > "${HOME}/.gurubashrc"
echo '. ${GURUBASH}/loader' >> "${HOME}/.gurubashrc"

ln -f -s "${GURUBASH}/core/defaults/profile" "${HOME}/.bashrc"
ln -f -s "${GURUBASH}/core/defaults/profile" "${HOME}/.profile"

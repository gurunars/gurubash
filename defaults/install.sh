#!/bin/bash

echo "export GURUBASH=${GURUBASH}" > ${HOME}/.gurubashrc
echo '. ${GURUBASH}/loader' >> ${HOME}/.gurubashrc

ln -f -s ${GURUBASH}/defaults/profile ${HOME}/.bashrc
ln -f -s ${GURUBASH}/defaults/profile ${HOME}/.profile

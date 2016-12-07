#!/bin/bash

for loader in ${HOME}/.gurubash/*/install.sh; do
    . ${loader}
done

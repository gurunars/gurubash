#!/bin/bash

bash ~/.gurubash/personal/install.sh

for loader in ${HOME}/.gurubash/*/install.sh; do
    . ${loader}
done

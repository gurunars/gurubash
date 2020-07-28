#!/bin/bash

mkdir -p ${HOME}/.personal

function backup {
    DIR=${HOME}/$1
    if [ -f "${DIR}" ]; then
        mv ${DIR} ${DIR}.bk
    fi
}

backup .bashrc
backup .profile
backup .bash_profile

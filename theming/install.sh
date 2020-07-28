#!/bin/bash
theming_file=${HOME}/.personal/theming

if [ -f ${theming_file} ]; then
    exit 0
fi

cp ~/.gurubash/theming/theming ${theming_file}
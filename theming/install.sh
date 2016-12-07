#!/bin/bash
theming_file=${HOME}/.personal/theming

if [ -f ${theming_file} ]; then
    return
fi

cp ~/.gurubash/theming/theming ${theming_file}
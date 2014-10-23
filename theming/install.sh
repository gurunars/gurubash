#!/bin/bash
theming_file=$HOME/.bash_env/cridentials

if [ -f $theming_file ]; then
    return
fi

cp ~/.gurubash/theming/theming $theming_file
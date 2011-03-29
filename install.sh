#!/bin/bash

DIR_NAME=$(cd `dirname $0` && pwd)
FILES=$DIR_NAME/*
for old_name in $FILES
do
    if [ $old_name != "$DIR_NAME/install.sh" ]; then
        new_name=.${old_name#$DIR_NAME/}
        echo "Installed $HOME/$new_name"
        cp $old_name $HOME/$new_name

    fi
done
echo "Personal config files were successfully installed."

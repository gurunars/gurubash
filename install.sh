#!/bin/bash

# Install all the settings for home directory

DIR_NAME=$(cd `dirname $0` && pwd)/home_settings
FILES=$DIR_NAME/*
for old_name in $FILES
do
    new_name=.${old_name#$DIR_NAME/}
    echo "Installed $HOME/$new_name"
    cp $old_name $HOME/$new_name
done
echo "Personal config files were successfully installed."

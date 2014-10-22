#!/bin/bash

# Backup user config

if [ -e $HOME/.bashrc ]; then
    mv $HOME/.bashrc $HOME/.bashrc.old
fi

# Install all the settings for home directory

DIR_NAME=$(cd `dirname $0` && pwd)/home_settings
FILES=$DIR_NAME/*
for old_name in $FILES
do
    new_name=.${old_name#$DIR_NAME/}
    rm -rf $HOME/$new_name
    cp -r $old_name $HOME/$new_name
    echo "Installed $HOME/$new_name"
done
echo "Personal config files were successfully installed."

# Restore cridentials

if [ -e $HOME/.bashrc.old ]; then
    mv $HOME/.bashrc.old $HOME/.bashrc
fi

# Configure the email and name (only once)

if grep __NAME $HOME/.bashrc 1> /dev/null
then
    echo "Type your first name and last named delimited with space."
    read name
    sed -i "s/__NAME/$name/g" $HOME/.bashrc
else
    name=$DEBFULLNAME
fi

if grep __EMAIL $HOME/.bashrc 1> /dev/null
then
    echo "Type your email"
    read email
    sed -i "s/__EMAIL/$email/g" $HOME/.bashrc
else
    email=$DEBEMAIL
fi

git config --global user.name "$name"
git config --global user.email "$email"

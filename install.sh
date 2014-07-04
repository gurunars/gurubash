#!/bin/bash

# Backup cridentials

if [ -e $HOME/.bash_cridentials ]; then
    mv $HOME/.bash_cridentials $HOME/.bash_cridentials.old
fi

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

# If it is root user, remove the cridentials

if [ `whoami` = "root" ]; then
    echo "Root user. Cridentials are not gonna be set."
    rm $HOME/.bash_cridentials
    exit 1
fi

# Restore cridentials

if [ -e $HOME/.bash_cridentials.old ]; then
    mv $HOME/.bash_cridentials.old $HOME/.bash_cridentials
fi

# Configure the email and name (only once)

if grep __NAME $HOME/.bash_cridentials 1> /dev/null
then
    echo "Type your first name and last named delimited with space."
    read name
    sed -i "s/__NAME/$name/g" $HOME/.bash_cridentials
else
    name=$DEBFULLNAME
fi

if grep __EMAIL $HOME/.bash_cridentials 1> /dev/null
then
    echo "Type your email"
    read email
    sed -i "s/__EMAIL/$email/g" $HOME/.bash_cridentials
else
    email=$DEBEMAIL
fi

git config --global user.name "$name"
git config --global user.email "$email"


#!/bin/bash

# Install all the packages required for proper work

sudo apt-get install -y debhelper git-buildpackage git-core dpkg-dev vim-nox \
                        ipython pylint python-django

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

# Create a home repositoory if it does not exist

REPO=$HOME/deb_repo

if ! grep $REPO /etc/apt/sources.list > /dev/null; then
    mkdir $REPO
    dpkg-scanpackages $REPO /dev/null | gzip -9c > $REPO/Packages.gz
    sudo sh -c 'echo "# Home repo" >> /etc/apt/sources.list'
    sudo sh -c 'echo "deb file:$HOME/deb_repo /" >> /etc/apt/sources.list'
    echo "Home repo created."
fi

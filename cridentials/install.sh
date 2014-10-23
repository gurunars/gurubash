#!/bin/bash
cred_file=$HOME/.bash_cridentials

cp ~/.gurubash/cridentials/bash_cridentials $cred_file

# Configure the email and name (only once)

if grep __NAME $cred_file 1> /dev/null
then
    echo "Type your first name and last named delimited with space."
    read name
    sed -i "s/__NAME/$name/g" $cred_file
fi

if grep __EMAIL $cred_file 1> /dev/null
then
    echo "Type your email"
    read email
    sed -i "s/__EMAIL/$email/g" $cred_file
fi

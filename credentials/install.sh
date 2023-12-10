#!/bin/bash
cred_file=${HOME}/.personal/credentials

username=$(eval whoami)
if [ "${username}" == "root" ];then
    exit 0
fi

if [ -f ${cred_file} ]; then
    exit 0
fi
cp ${GURUBASH}/credentials/credentials ${cred_file}

# Configure the email and name (only once)

if grep __NAME ${cred_file} 1> /dev/null; then
    echo "Type your first name and last named delimited with space."
    read name
    perl -pi -e s/__NAME/${name}/g ${cred_file}
else
    echo "NAME is already set"
fi

if grep __EMAIL ${cred_file} 1> /dev/null; then
    echo "Type your email"
    read email
    perl -pi -e s/__EMAIL/${email}/g ${cred_file}
else
    echo "EMAIL is already set"
fi

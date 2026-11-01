#!/bin/bash

set -e

cred_file="${HOME}/.personal/credentials"

username=$(id -un)
if [ "${username}" == "root" ]; then
    exit 0
fi

if [ -f "${cred_file}" ]; then
    exit 0
fi
mkdir -p "$(dirname "${cred_file}")"
cp "${GURUBASH}/credentials/credentials" "${cred_file}"

# Configure the email and name (only once). The values go through the
# environment, so perl never interpolates them: an `@` or a space is data.

if grep -q __NAME "${cred_file}"; then
    echo "Type your first name and last name, delimited with space."
    read -r name
    NAME="${name}" perl -pi -e 's/__NAME/$ENV{NAME}/g' "${cred_file}"
else
    echo "NAME is already set"
fi

if grep -q __EMAIL "${cred_file}"; then
    echo "Type your email"
    read -r email
    EMAIL="${email}" perl -pi -e 's/__EMAIL/$ENV{EMAIL}/g' "${cred_file}"
else
    echo "EMAIL is already set"
fi

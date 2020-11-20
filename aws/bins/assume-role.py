#!/usr/bin/env python
import argparse
import os
import subprocess
import sys


def set_env(assumed_role_name, access_key_id, secret_access_key, session_token):
    os.environ.update(dict(
        AWS_ACCESS_KEY_ID=access_key_id,
        AWS_SECRET_ACCESS_KEY=secret_access_key,
        AWS_SESSION_TOKEN=session_token,
        AWS_ASSUMED_ROLE=assumed_role_name
    ))


def assume_with_csv_args():
    pass


QUERY_PARAMS = ["AccessKeyId", "SecretAccessKey", "SessionToken"]


def get_creds_from_role_and_external_id(args):
    aws_role, external_id = "", None

    if not args:
        exit(1)
    elif len(args) == 1:
        aws_role = args[0]
    else:
        aws_role = args[0]
        external_id = args[1]

    query = ",".join(["Credentials.{}".format(it) for it in QUERY_PARAMS])

    params = [
        "aws", "sts", "assume-role",
        "--role-arn", aws_role,
        "--role-session-name",
        "Personal-assumed-{}-role".format(os.environ.get("USER", "anonymours")),
        "--query", "'[{}]'".format(query),
        "--output", "text"
    ]

    if external_id is not None:
        params.extend([
            "--external-id", external_id
        ])

    return aws_role, subprocess.check_output(
        " ".join(params), stderr=subprocess.STDOUT, shell=True
    ).decode("utf-8").replace("\n", "").split("\t")


def main():
    #subprocess.call(['/bin/bash'])
    args = sys.argv[1:]
    if not args:
        exit(1)
    title, results = get_creds_from_role_and_external_id(args)
    set_env(title, *results)




if __name__ == "__main__":
    main()

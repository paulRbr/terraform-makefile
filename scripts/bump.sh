#!/usr/bin/env bash

set -eo pipefail

current_version=$(cat VERSION)
bump_version=${1}

if [ -n "${bump_version}" ]
then
    echo "Checking version ${bump_version} of Terraform..."
    tmp_file=$(mktemp /tmp/tf-make.XXX)
    if wget --quiet -O "${tmp_file}" "https://releases.hashicorp.com/terraform/${bump_version}"
    then
        printf "\\033[32mOK\\033[0m ✔️\\n"
        echo "Bumping version from ${current_version} to ${bump_version}..."
        find . -maxdepth 1 -type f -exec sed -i "s|${current_version}|${bump_version}|" {} \;
        printf "\\033[32mDONE!\\033[0m ✔️\\n"
        echo "Bye 👋"
    else
        printf "\\033[31mFAILED!\\033[0m ❌\\n"
        echo "Version ${bump_version} does not seem to exist."
        echo "Exiting 👋"
        exit 1
    fi
else
    echo "Usage: ${0} <terraform_version>"
    exit 1
fi

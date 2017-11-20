# ------------------
# TERRAFORM-MAKEFILE
# v0.11.0
# ------------------
#
# This Makefile is maintained on Github.com.
# Please contribute upstream any changes by opening pull requests:
# https://github.com/paulRbr/terraform-makefile/pull/new/master
# Thanks! - Paul(rbr)
#
#!/bin/bash -e

valid_identifier()
{
    echo "$1" | tr '[:lower:]' '[:upper:]' | tr -cs '[:alpha:][:digit:]\n' '_'
}

key="$(valid_identifier "${provider}")_$(valid_identifier "${env}")_KEY"
secret="$(valid_identifier "${provider}")_$(valid_identifier "${env}")_SECRET"

if (which pass >/dev/null 2>&1); then
    pass_key="$(pass "terraform/${provider}/${env}/access_key")"
    pass_secret="$(pass "terraform/${provider}/${env}/secret")"

    declare "${key}"="${pass_key}"
    declare "${secret}"="${pass_secret}"
fi

case $provider in
    aws)
        if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
            declare -x "AWS_ACCESS_KEY_ID=${!key}"
            declare -x "AWS_SECRET_ACCESS_KEY=${!secret}"
        fi
        ;;
    azurerm)
        if [ -z "${ARM_CLIENT_ID}" ]; then
            declare -x "ARM_CLIENT_ID=${!key}"
            declare -x "ARM_CLIENT_SECRET=${!secret}"
        fi
        ;;
    "do")
        if [ -z "${DIGITALOCEAN_TOKEN}" ]; then
            declare -x "DIGITALOCEAN_TOKEN=${!secret}"
        fi
        ;;
    google)
        if [ -z "${GOOGLE_CREDENTIALS}" ]; then
            declare -x "GOOGLE_CREDENTIALS=${!secret}"
        fi
        ;;
    scaleway)
        if [ -z "${SCALEWAY_ORGANIZATION}" ]; then
            declare -x "SCALEWAY_ORGANIZATION=${!key}"
            declare -x "SCALEWAY_TOKEN=${!secret}"
        fi
        ;;
    ovh)
        if [ -z "${OS_PASSWORD}" ]; then
            declare -x "OS_USERNAME=${!key}"
            declare -x "OS_PASSWORD=${!secret}"
        elif [ -z "${OS_AUTH_TOKEN}" ]; then
            declare -x "OS_AUTH_TOKEN=${!secret}"
        fi
        ;;
esac

cd "providers/${provider}/${env}"
terraform "$@"

# ------------------
# TERRAFORM-MAKEFILE
# v0.11.1
# ------------------
#
# This Makefile is maintained on Github.com.
# Please contribute upstream any changes by opening pull requests:
# https://github.com/paulRbr/terraform-makefile/pull/new/master
# Thanks! - Paul(rbr)
#
#!/usr/bin/env bash
set -e

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

if [ -n "${VAULT_ADDR}" ]; then
    if [ -z "${VAULT_TOKEN}" ]; then
        if [ -n "${VAULT_ROLE_ID}" ] && [ -n "${VAULT_SECRET_ID}" ]; then
            VAULT_TOKEN=$(curl -s -X POST -d "{\"role_id\":\"${VAULT_ROLE_ID}\",\"secret_id\":\"${VAULT_SECRET_ID}\"}" "${VAULT_ADDR}/v1/auth/approle/login" | jq -r .auth.client_token)
        else
            echo "VAULT_TOKEN or (VAULT_ROLE_ID and VAULT_SECRET_ID) must be set!"
            exit
        fi
    fi

    case $provider in
        aws)
            # We use STS by default but if we need to perform IAM actions we can't use it
            if [ "${iam}" == "true" ]; then
                creds=$(curl -s -X POST -H "X-Vault-Token: ${VAULT_TOKEN}" -d "{\"ttl\":\"${ttl}\"}" "${VAULT_ADDR}/v1/aws_${env}/creds/${role}" | jq .data)
            else
                creds=$(curl -s -X POST -H "X-Vault-Token: ${VAULT_TOKEN}" -d "{\"ttl\":\"${ttl}\"}" "${VAULT_ADDR}/v1/aws_${env}/sts/${role}" | jq .data)
                declare "${token}"=$(echo ${creds} | jq -r .security_token)
            fi

            declare "${key}"=$(echo ${creds} | jq -r .access_key)
            declare "${secret}"=$(echo ${creds} | jq -r .secret_key)
            ;;
    esac
fi

case $provider in
    aws)
        if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
            declare -x "AWS_ACCESS_KEY_ID=${!key}"
            declare -x "AWS_SECRET_ACCESS_KEY=${!secret}"

            if [ -n "${token}" ]; then
                declare -x "AWS_SESSION_TOKEN=${!token}"
            fi
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

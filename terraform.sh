#!/usr/bin/env bash
# ------------------
# TERRAFORM-MAKEFILE
# v0.14.11
# ------------------
#
# This Makefile is maintained on Github.com.
# Please contribute upstream any changes by opening pull requests:
# https://github.com/paulRbr/terraform-makefile/pull/new/master
# Thanks! - Paul(rbr)
#

set -e

if [ -z "${provider}" ]; then
    echo "'provider' variable must be set"
    exit
fi

if [ -z "${env}" ]; then
    echo "'env' variable must be set"
    exit
fi

vault_path=${vault_path:-""}
vault_ttl=${vault_ttl:-"15m"}

vault_aws=${vault_aws:-"true"}
vault_aws_role=${vault_aws_role:-"admin"}
vault_aws_iam=${vault_aws_iam:-"false"}

valid_identifier()
{
    echo "$1" | tr '[:lower:]' '[:upper:]' | tr -cs '[:alpha:][:digit:]\n' '_'
}

# Split provider variable on commas ','
while IFS=',' read -ra providers; do
    for oneProvider in "${providers[@]}"; do
        key="$(valid_identifier "${oneProvider}")_$(valid_identifier "${env}")_KEY"
        secret="$(valid_identifier "${oneProvider}")_$(valid_identifier "${env}")_SECRET"
        token="$(valid_identifier "${oneProvider}")_$(valid_identifier "${env}")_TOKEN"

        if command -v pass >/dev/null 2>&1; then
            pass_key="$(pass "terraform/${oneProvider}/${env}/access_key" || echo '')"
            pass_secret="$(pass "terraform/${oneProvider}/${env}/secret" || echo '')"
            pass_token="$(pass "terraform/${oneProvider}/${env}/token" || echo '')"

            if [ -n "${pass_key}" ] && [ -n "${pass_secret}" ]; then
                declare "${key}"="${pass_key}"
                declare "${secret}"="${pass_secret}"
            fi
            if [ -n "${pass_token}" ]; then
                declare "${token}"="${pass_token}"
            fi
        fi

        if [ -n "${VAULT_ADDR}" ]; then
            if [ -z "${VAULT_TOKEN}" ]; then
                if [ -n "${VAULT_ROLE_ID}" ] && [ -n "${VAULT_SECRET_ID}" ]; then
                    declare -x "VAULT_TOKEN"=$(curl -s -X POST -d "{\"role_id\":\"${VAULT_ROLE_ID}\",\"secret_id\":\"${VAULT_SECRET_ID}\"}" "${VAULT_ADDR}/v1/auth/approle/login" | jq -r .auth.client_token)
                    if [ -z "${VAULT_TOKEN}" ] || [ "${VAULT_TOKEN}" == "null" ]; then
                        echo "Error fetching 'VAULT_TOKEN' from 'VAULT_ROLE_ID' and 'VAULT_SECRET_ID'"
                        exit
                    fi
                else
                    echo "'VAULT_TOKEN' or ( 'VAULT_ROLE_ID' and 'VAULT_SECRET_ID' ) must be set!"
                    exit
                fi
            fi

            if [ "${vault_aws}" == "true" ]; then
                if [ -z "${vault_path}" ]; then
                    vault_path="aws"
                fi

                if [ -z "${vault_aws_role}" ]; then
                    echo "'vault_aws_role' variable must be set"
                    exit
                fi

                # We use STS by default but if we need to perform IAM actions we can't use it
                if [ "${vault_aws_iam}" == "true" ]; then
                    creds=$(curl -s -X GET -H "X-Vault-Token: ${VAULT_TOKEN}" -d "{\"ttl\":\"${vault_ttl}\"}" "${VAULT_ADDR}/v1/${vault_path}/creds/${vault_aws_role}" | jq .data)
                else
                    creds=$(curl -s -X GET -H "X-Vault-Token: ${VAULT_TOKEN}" -d "{\"ttl\":\"${vault_ttl}\"}" "${VAULT_ADDR}/v1/${vault_path}/sts/${vault_aws_role}" | jq .data)
                    declare -x "AWS_SESSION_TOKEN"=$(echo ${creds} | jq -r .security_token)
                fi

                if [ -z "$(echo ${creds})" ] || [ "$(echo ${creds} | jq -r .access_key)" == "null" ]; then
                    echo "Unable to fetch AWS credentials from Vault"
                    exit
                fi

                declare -x "AWS_ACCESS_KEY_ID"=$(echo ${creds} | jq -r .access_key)
                declare -x "AWS_SECRET_ACCESS_KEY"=$(echo ${creds} | jq -r .secret_key)

                echo "Fetched AWS credentials from Vault."
            fi
        fi

        case $oneProvider in
            aws)
                if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
                    declare -x "AWS_ACCESS_KEY_ID=${!key}"
                    declare -x "AWS_SECRET_ACCESS_KEY=${!secret}"

                    if [ -n "${!token}" ]; then
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
            hetzner)
                if [ -z "${HCLOUD_TOKEN}" ]; then
                    declare -x "HCLOUD_TOKEN=${!token}"
                fi
                ;;
            scaleway)
                if [ -z "${SCW_ACCESS_KEY}" ]; then
                    declare -x "SCW_ACCESS_KEY=${!key}"
                    declare -x "SCW_SECRET_KEY=${!secret}"
                    declare -x "SCW_DEFAULT_ORGANIZATION_ID=${!token}"
                fi
                # This is a hack to be able to use S3 tf backend on a scaleway object storage
                #   and because terraform doesn't allow interpolation in backend config:
                #   https://github.com/hashicorp/terraform/issues/13022
                if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
                    declare -x "AWS_ACCESS_KEY_ID=${!key}"
                    declare -x "AWS_SECRET_ACCESS_KEY=${!secret}"
                fi
                ;;
            ovh)
                if [ -z "${OS_PASSWORD}" ]; then
                    declare -x "OS_USERNAME=${!key}"
                    declare -x "OS_PASSWORD=${!secret}"
                elif [ -z "${OS_AUTH_TOKEN}" ]; then
                    declare -x "OS_AUTH_TOKEN=${!secret}"
                fi
                if [ -z "${OVH_APPLICATION_KEY}" ]; then
                    declare -x "OVH_APPLICATION_KEY=${!key}"
                    declare -x "OVH_APPLICATION_SECRET=${!secret}"
                    declare -x "OVH_CONSUMER_KEY=${!token}"
                fi
                ;;
            gandi)
                if [ -z "${GANDI_SHARING_ID}" ]; then
                    declare -x "GANDI_SHARING_ID=${!key}"
                    declare -x "GANDI_KEY=${!secret}"
                fi
        esac

    done
done <<< "${provider}"

if [ -n "$debug" ]; then
    declare -x "TF_LOG=$debug"
fi

cd "providers/${provider}/${env}"
terraform "$@"

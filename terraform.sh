# ------------------
# TERRAFORM-MAKEFILE
# v0.1.0
# ------------------
#
# This Makefile is maintained on Github.com.
# Please contribute upstream any changes by opening pull requests:
# https://github.com/paulRbr/terraform-makefile/pull/new/master
# Thanks! - Paul(rbr)
#
#!/bin/bash -e

key="$(echo "${provider}" | tr '[:lower:]' '[:upper:]')_$(echo "${env}" | tr '[:lower:]' '[:upper:]')_KEY"
secret="$(echo "${provider}" | tr '[:lower:]' '[:upper:]')_$(echo "${env}" | tr '[:lower:]' '[:upper:]')_SECRET"

if (which pass >/dev/null 2>&1); then
  pass_key="$(pass "terraform/${provider}/${env}/access_key")"
  pass_secret="$(pass "terraform/${provider}/${env}/secret")"

  declare "${key}"="${pass_key}"
  declare "${secret}"="${pass_secret}"
fi

case $provider in
  aws)
    declare "AWS_ACCESS_KEY_ID=${!key}"
    declare "AWS_SECRET_ACCESS_KEY=${!secret}"
    ;;
  azurerm)
    declare "ARM_CLIENT_ID=${!key}"
    declare "ARM_CLIENT_SECRET=${!secret}"
    :;;
  "do")
    declare "DIGITALOCEAN_TOKEN=${!secret}"
    :;;
  google)
    declare "GOOGLE_CREDENTIALS=${!secret}"
    :;;
  scaleway)
    declare "SCALEWAY_ORGANIZATION=${!key}"
    declare "SCALEWAY_TOKEN=${!secret}"
    :;;
esac

cd "${wd}" && terraform $@

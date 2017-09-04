# This MAKEFILE is maintained open-source on Github.com
# If you make any modification to this file please open a Pull Request
# with your changes on https://github.com/paulRbr/terraform-makefile
#
# Thanks!
# - Paul(rbr)
#
#!/bin/bash -e

if (which pass >/dev/null 2>&1); then
   provider_key="$(pass ${provider}/access_key)"
   provider_token="$(pass ${provider}/token)"
   declare "TF_VAR_${provider}_access_key"=$provider_key
   declare "TF_VAR_${provider}_token"=$provider_token
fi

export TF_VAR_${provider}_access_key
export TF_VAR_${provider}_token

cd ${wd} && terraform $@

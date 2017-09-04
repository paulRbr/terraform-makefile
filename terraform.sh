# This MAKEFILE is maintained open-source on Github.com
# If you make any modification to this file please open a Pull Request
# with your changes on https://github.com/paulRbr/terraform-makefile
#
# Thanks!
# - Paul(rbr)
#

declare "TF_VAR_${provider}_access_key"="$(pass ${provider}/access_key)"
declare "TF_VAR_${provider}_token"="$(pass ${provider}/token)"
export TF_VAR_${provider}_access_key
export TF_VAR_${provider}_token

cd ${wd}

terraform $@

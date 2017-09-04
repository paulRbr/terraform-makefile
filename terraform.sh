#!/bin/bash

declare "TF_VAR_${provider}_access_key"="$(pass ${provider}/access_key)"
declare "TF_VAR_${provider}_token"="$(pass ${provider}/token)"
export TF_VAR_${provider}_access_key
export TF_VAR_${provider}_token

cd ${wd}

terraform $@

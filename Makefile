# This MAKEFILE is maintained open-source on Github.com
# If you make any modification to this file please open a Pull Request
# with your changes on https://github.com/paulRbr/terraform-makefile
#
# Thanks!
# - Paul(rbr)

##
# TERRAFORM INSTALL
##
version  ?= "0.10.3"
os       ?= $(shell uname|tr A-Z a-z)
ifeq ($(shell uname -m),x86_64)
  arch   ?= "amd64"
endif
ifeq ($(shell uname -m),i686)
  arch   ?= "386"
endif
ifeq ($(shell uname -m),aarch64)
  arch   ?= "arm"
endif

##
# MAKEFILE ARGUMENTS
##
opts     ?= $(args)
provider ?= ""
env      ?= ""

##
# INTERNAL VARIABLES
##
ifneq ("$(provider)", "")
  wd     ?= providers/$(provider)/$(env)
else
  wd     ?= "."
endif

##
# TASKS
##
.PHONY: install
install: ## make install # Install terraform and dependencies
	@wget -O /usr/bin/terraform.zip https://releases.hashicorp.com/terraform/0.10.3/terraform_$(version)_$(os)_$(arch).zip
	@unzip -d /usr/bin /usr/bin/terraform.zip && rm /usr/bin/terraform.zip
	@terraform --version
	@wd=$(wd) terraform.sh init

.PHONY: lint
lint: ## make lint # Rewrites config to canonical format
	@terraform fmt $(opts)

.PHONY: list
list: ## make list # List infra resources
	@wd=$(wd) terraform.sh show $(opts)

.PHONY: dry-run
dry-run: ## make dry-run # Dry run resources changes
	@wd=$(wd) terraform.sh plan $(opts)

.PHONY: run
run: ## make run # Execute resources changes
	@wd=$(wd) terraform.sh apply $(opts)

.PHONY: destroy
destroy: ## make destroy # Destroy resources
	@wd=$(wd) terraform.sh destroy $(opts)

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

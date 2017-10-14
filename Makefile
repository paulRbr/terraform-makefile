# ------------------
# TERRAFORM-MAKEFILE
# v0.10.7
# ------------------
#
# This Makefile is maintained on Github.com.
# Please contribute upstream any changes by opening pull requests:
# https://github.com/paulRbr/terraform-makefile/pull/new/master
# Thanks! - Paul(rbr)

##
# TERRAFORM INSTALL
##
version  ?= "0.10.7"
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
ifeq ("$(shell which terraform)", "")
  install ?= "true"
endif
ifeq ("$(upgrade)", "true")
  install ?= "true"
endif

##
# TASKS
##
.PHONY: install
install: ## make install # Install terraform and dependencies
ifeq ($(install),"true")
	@wget -O /usr/bin/terraform.zip https://releases.hashicorp.com/terraform/$(version)/terraform_$(version)_$(os)_$(arch).zip
	@unzip -d /usr/bin /usr/bin/terraform.zip && rm /usr/bin/terraform.zip
endif
	@terraform --version
	@bash terraform.sh init

.PHONY: lint
lint: ## make lint # Rewrites config to canonical format
	@terraform fmt -diff=true -check $(opts)

.PHONY: validate
validate: ## make validate # Basic syntax check
	@bash terraform.sh validate $(opts)

.PHONY: list
list: ## make list # List infra resources
	@bash terraform.sh show $(opts)

.PHONY: dry-run
dry-run: ## make dry-run # Dry run resources changes
	@bash terraform.sh plan $(opts)

.PHONY: run
run: ## make run # Execute resources changes
	@bash terraform.sh apply $(opts)

.PHONY: destroy
destroy: ## make destroy # Destroy resources
	@bash terraform.sh destroy $(opts)

help:
	@printf "\033[32mTerraform-makefile v$(version)\033[0m\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

# ------------------
# TERRAFORM-MAKEFILE
# v0.11.1
# ------------------
#
# This Makefile is maintained on Github.com.
# Please contribute upstream any changes by opening pull requests:
# https://github.com/paulRbr/terraform-makefile/pull/new/master
# Thanks! - Paul(rbr)

##
# TERRAFORM INSTALL
##
version  ?= "0.11.1"
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
# INTERNAL VARIABLES
##
ifeq ("$(shell which terraform)", "")
  install ?= "true"
endif
# Read all subsquent tasks as arguments of the first task
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(args) $(RUN_ARGS):;@:)
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))

##
# MAKEFILE ARGUMENTS
##
provider ?= ""
env      ?= ""
ifeq ("$(upgrade)", "true")
  install ?= "true"
endif

##
# TASKS
##
.PHONY: install
install: ## Install terraform and dependencies
ifeq ($(install),"true")
	@wget -O /usr/bin/terraform.zip https://releases.hashicorp.com/terraform/$(version)/terraform_$(version)_$(os)_$(arch).zip
	@unzip -d /usr/bin /usr/bin/terraform.zip && rm /usr/bin/terraform.zip
endif
	@terraform --version
	@bash $(dir $(mkfile_path))/terraform.sh init

.PHONY: fmt
fmt:
	@terraform fmt $(args) $(RUN_ARGS)
.PHONY: lint
lint: ## Rewrites config to canonical format
	@terraform fmt -diff=true -check $(args) $(RUN_ARGS)

.PHONY: validate
validate: ## Basic syntax check
	@bash $(dir $(mkfile_path))/terraform.sh validate $(args) $(RUN_ARGS)

.PHONY: show
show: ## List infra resources
	@bash $(dir $(mkfile_path))/terraform.sh show $(args) $(RUN_ARGS)

.PHONY: refresh
refresh: ## Refresh infra resources
	@bash $(dir $(mkfile_path))/terraform.sh refresh $(args) $(RUN_ARGS)

.PHONY: console
console: ## Console infra resources
	@bash $(dir $(mkfile_path))/terraform.sh console $(args) $(RUN_ARGS)

.PHONY: import
import: ## Import infra resources
	@bash $(dir $(mkfile_path))/terraform.sh import $(args) $(RUN_ARGS)

.PHONY: taint
taint: ## Taint infra resources
	bash $(dir $(mkfile_path))terraform.sh taint -module=$(module) $(args) $(RUN_ARGS)

.PHONY: workspace
workspace: ## Workspace infra resources
	bash $(dir $(mkfile_path))terraform.sh workspace $(args) $(RUN_ARGS)

.PHONY: state
state: ## Inspect or change the remote state of your resources
	@bash $(dir $(mkfile_path))/terraform.sh state $(args) $(RUN_ARGS)

.PHONY: plan
plan: dry-run
.PHONY: dry-run
dry-run: install ## Dry run resources changes
	@bash $(dir $(mkfile_path))/terraform.sh plan $(args) $(RUN_ARGS)

.PHONY: apply
apply: run
.PHONY: run
run: ## Execute resources changes
	@bash $(dir $(mkfile_path))/terraform.sh apply $(args) $(RUN_ARGS)

.PHONY: destroy
destroy: ## Destroy resources
	@bash $(dir $(mkfile_path))/terraform.sh destroy $(args) $(RUN_ARGS)

help:
	@printf "\033[32mTerraform-makefile v$(version)\033[0m\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

# ------------------
# TERRAFORM-MAKEFILE
# v0.14.11
# ------------------
#
# Terraform makefile is a helper to run terraform commands
# on separate providers
#
# Copyright (C) 2017  Paul(r)B.r
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# This Makefile is maintained on Github.com.
# Please contribute upstream any changes by opening pull requests:
# https://github.com/paulRbr/terraform-makefile/pull/new/master
# Thanks! - Paul(rbr)

##
# TERRAFORM INSTALL
##
version  ?= "0.14.11"
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
# Read all subsquent tasks as arguments of the first task
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(args) $(RUN_ARGS):;@:)
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
landscape   := $(shell command -v landscape 2> /dev/null)
terraform   := $(shell command -v terraform 2> /dev/null)
debug       :=

##
# MAKEFILE ARGUMENTS
##
ifndef terraform
  install ?= "true"
endif
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
	@bash $(dir $(mkfile_path))/terraform.sh init $(args)

.PHONY: fmt
fmt: ## Rewrites config to canonical format
	@bash $(dir $(mkfile_path))/terraform.sh fmt $(args)

.PHONY: lint
lint: ## Lint the HCL code
	@bash $(dir $(mkfile_path))/terraform.sh fmt -diff=true -check $(args) $(RUN_ARGS)

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

.PHONY: untaint
untaint: ## Untaint infra resources
	bash $(dir $(mkfile_path))terraform.sh untaint -module=$(module) $(args) $(RUN_ARGS)

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
ifndef landscape
	@bash $(dir $(mkfile_path))/terraform.sh plan $(args) $(RUN_ARGS)
else
	@bash $(dir $(mkfile_path))/terraform.sh plan $(args) $(RUN_ARGS) | landscape
endif

.PHONY: apply
apply: run
.PHONY: run
run: ## Execute resources changes
	@bash $(dir $(mkfile_path))/terraform.sh apply $(args) $(RUN_ARGS)

.PHONY: destroy
destroy: ## Destroy resources
	@bash $(dir $(mkfile_path))/terraform.sh destroy $(args) $(RUN_ARGS)

.PHONY: raw
raw: ## Raw command sent to terraform
	@bash $(dir $(mkfile_path))/terraform.sh $(RUN_ARGS) $(args)

help:
	@printf "\033[32mTerraform-makefile v$(version)\033[0m\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

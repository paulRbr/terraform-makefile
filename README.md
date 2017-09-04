# Makefile for Terraform users

This repository provides a Makefile to give you a simple interface for Terraform.

## Why?

- Simplify your CLI terraform runs
- Don't Repeat Yourself while typing terraform commands
- Easier adoption for people that are not used to Terraform
- Document common usage
- Unique entrypoint script for credentials management

## Installation

Simply download the `Makefile` and the `terraform.sh` files in your terraform configuration directory.

    wget -O Makefile https://raw.githubusercontent.com/paulRbr/terraform-makefile/master/Makefile
    wget -O terraform.sh https://raw.githubusercontent.com/paulRbr/terraform-makefile/master/terraform.sh

## Commands

This is the list of commands made available

~~~bash
> make
destroy                        make destroy # Destroy resources
dry-run                        make dry-run # Dry run resources changes
install                        make install # Install terraform and dependencies
lint                           make lint # Rewrites config to canonical format
list                           make list # List infra resources
run                            make run # Execute resources changes
~~~

## Variables

This is the explanation of variables that can be passed to commands:


| Name      | Default | Description | Example |
| --------- | ------- | ----------- | ------- |
| `provider`| -       | Name of the cloud provider to target | If you have an terraform file in `provider/aws/production/production.tf` you will be able to `make run provider=aws env=production`  |
| `env`     | -       | Name of the environment you want to use | If you have an terraform file in `provider/google/production/production.tf` you will be able to `make run provider=google env=production` |
| `args`    | -       | Add terraform understandable arguments | `make dry-run args='-no-color'` |

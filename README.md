# Makefile for Terraform users

This repository provides a Makefile to give you a simple interface for [Terraform](https://www.terraform.io/).

## Why?

- Simplify your CLI terraform runs
- Don't Repeat Yourself while typing terraform commands
- Easier adoption for people that are not used to Terraform
- Document common usage
- Unique entrypoint script for credentials management (only for AWS, Azure, DigitalOcean, Google and Scaleway for now)
  - either passing ENV variables. E.g. `<PROVIDER>_<ENV>_SECRET` will be mapped to `DIGITALOCEAN_TOKEN` if `provider=do` is provided as variable
  - either using [`pass`](https://www.passwordstore.org/) as local secret manager. E.g. password `terraform/<provider>/<env>/secret` will be mapped to `DIGITALOCEAN_TOKEN` if `provider=do` is provided as variable

## Installation

Simply download the `Makefile` and the `terraform.sh` files in your terraform configuration directory.

    wget -N https://raw.githubusercontent.com/paulRbr/terraform-makefile/master/{Makefile,terraform.sh}

## Convention

This makefile assumes your terraform configuration files are stored as such:

```
providers/
├── aws
│   ├── prod
│   │   └── empty.tf
│   └── test
│       └── empty.tf
├── do
│   └── prod
│       └── empty.tf
├── google
│   ├── prod
│   │   └── empty.tf
│   └── test
│       └── empty.tf
└── scaleway
    └── prod
        └── empty.tf
```

I.e. `providers/<provider>/<env>/*.tf`

## Commands

List of commands made available

~~~bash
> make
Terraform-makefile v0.10.4
destroy                        make destroy # Destroy resources
dry-run                        make dry-run # Dry run resources changes
install                        make install # Install terraform and dependencies
lint                           make lint # Rewrites config to canonical format
list                           make list # List infra resources
run                            make run # Execute resources changes
validate                       make validate # Basic syntax check
~~~

## Variables

Details of the variables that can be passed to commands:


| Name      | Default | Values | Description | Example |
| --------- | ------- | ------ | ----------- | ------- |
| `provider`| -       | `aws`<br/>`azure`<br/>`do`<br/>`google`<br/>`scaleway` | Name of the cloud provider to target | With your terraform file in `provider/aws/production/production.tf` you will be able to `make dry-run provider=aws env=production`  |
| `env`     | -       | `String` | Name of the environment you want to use | With a terraform file in `provider/google/production/production.tf` you will be able to `make dry-run provider=google env=production` |
| `args`    | -       | `String` | Add terraform understandable arguments | `make dry-run args='-no-color'` |

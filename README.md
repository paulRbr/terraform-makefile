# Makefile for Terraform users

[![Build Status](https://travis-ci.org/paulRbr/terraform-makefile.svg?branch=master)](https://travis-ci.org/paulRbr/terraform-makefile) [![Docker Hub](https://img.shields.io/docker/automated/swcc/terraform-makefile.svg)](https://hub.docker.com/r/swcc/terraform-makefile/)

This repository provides a Makefile to give you a simple interface for [Terraform](https://www.terraform.io/).

## Why?

- Simplify your CLI terraform runs
- Don't Repeat Yourself while typing terraform commands
- Easier adoption for people that are not used to Terraform
- Document common usage
- Unique entrypoint script for credentials management (only for AWS, Azure, DigitalOcean, Google, Hetzner and Scaleway for now)
  - either passing ENV variables. E.g. `<PROVIDER>_<ENV>_SECRET` will be mapped to `DIGITALOCEAN_TOKEN` if `provider=do` is provided as variable
  - either using [`pass`](https://www.passwordstore.org/) as local secret manager. E.g. password `terraform/<provider>/<env>/secret` will be mapped to `DIGITALOCEAN_TOKEN` if `provider=do` is provided as variable
  - either using [`vault`](https://www.vaultproject.io/) as distributed secret manager (Only for AWS credentials for now). E.g. by using `VAULT_ADDR` and either `VAULT_ROLE_ID` + `VAULT_SECRET_ID` or directly a `VAULT_TOKEN` your credentials will automatically be fetched into your vault.

## Installation

### Package install

(for now packages are only published in [Github releases](https://github.com/paulRbr/terraform-makefile/releases))

    wget https://github.com/paulRbr/terraform-makefile/releases/download/<version>/tf-make_<version>_amd64.deb
    dpkg -i tf-make_<version>.deb

### Manual install

Simply download the `Makefile` and the `terraform.sh` files in safe place.

    mkdir -p /opt/terraform
    cd /opt/terraform
    wget -N https://raw.githubusercontent.com/paulRbr/terraform-makefile/master/{Makefile,terraform.sh}

Then you will need to add the `tf-make` binary (it's a simple bash script) in your $PATH. WARNING: you'll need to change the Makefile path in the `tf-make` file.

## Convention

This makefile assumes your terraform configuration files are stored in a specific directory structure:

I.e. `providers/<provider>/<env>/*.tf`

E.g. example for all supported providers:
```
providers/
├── aws
│   ├── prod
│   │   └── config.tf
│   └── test
│       └── config.tf
├── do
│   └── prod
│       └── config.tf
├── google
│   ├── prod
│   │   └── config.tf
│   └── test
│       └── config.tf
├── hetzner,scaleway
│   └── test
│       └── config.tf
├── hetzner
│   └── prod
│       └── config.tf
└── scaleway
    └── prod
        └── config.tf
```


_Note: the `provider` name can be a combination of multiple providers when you are in a multi-cloud environment. E.g. `providers/hetzner,scaleway/prod/config.tf`._

## Commands

List of commands made available

~~~bash
> make
Terraform-makefile v0.14.7

console                        Console infra resources
destroy                        Destroy resources
dry-run                        Dry run resources changes
fmt                            Rewrites config to canonical format
import                         Import infra resources
install                        Install terraform and dependencies
lint                           Lint the HCL code
raw                            Raw command sent to terraform
refresh                        Refresh infra resources
run                            Execute resources changes
show                           List infra resources
state                          Inspect or change the remote state of your resources
taint                          Taint infra resources
untaint                        Untaint infra resources
validate                       Basic syntax check
workspace                      Workspace infra resources
~~~

## Variables

Details of the variables that can be passed to commands:


| Name       | Default | Values                                                                                                                       | Description                             | Example                                                                                                                                                                                                                                                                                                                                        |
| ---------  | ------- | ------                                                                                                                       | -----------                             | -------                                                                                                                                                                                                                                                                                                                                        |
| `provider` | -       | `aws`<br/>`azure`<br/>`do`<br/>`google`<br/>`hetzner`<br/>`scaleway`<br/>or any combination of those separated by commas `,` | Name of the cloud provider(s) to target | With your terraform file in `provider/aws/production/production.tf` you will be able to `make dry-run provider=aws env=production`<br/>With a terraform file in `provider/hetzner,scaleway/production/config.tf` you will be able to `make dry-run provider=hetzner,scaleway env=production` and have credentials for both providers available |
| `env`      | -       | `String`                                                                                                                     | Name of the environment you want to use | With a terraform file in `provider/google/production/production.tf` you will be able to `make dry-run provider=google env=production`                                                                                                                                                                                                          |
| `args`     | -       | `String`                                                                                                                     | Add terraform understandable arguments  | `make dry-run args='-no-color'`                                                                                                                                                                                                                                                                                                                |

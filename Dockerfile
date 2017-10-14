FROM hashicorp/terraform:0.10.7

RUN  apk add --update make bash

WORKDIR /opt/terraform
COPY .  .

VOLUME [ /opt/terraform/providers ]
VOLUME [ /opt/terraform/modules ]

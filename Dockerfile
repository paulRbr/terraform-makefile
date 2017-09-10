FROM hashicorp/terraform:0.10.4

RUN  apk add --update make bash

WORKDIR /opt/terraform
COPY .  .

VOLUME [ /opt/terraform/providers ]
VOLUME [ /opt/terraform/modules ]

FROM hashicorp/terraform:0.11.2

RUN \
apk add --no-cache make bash ca-certificates jq curl ;\
echo -e "#"'!'"/usr/bin/env bash\n\nmake -f /opt/terraform/Makefile "'$'"@" > /usr/bin/tf-make ;\
chmod +x /usr/bin/tf-make

WORKDIR /opt/terraform
ADD . .

VOLUME [ /opt/terraform/providers ]
VOLUME [ /opt/terraform/modules ]

ENTRYPOINT [ "/usr/bin/tf-make" ]

FROM hashicorp/terraform:0.10.7

RUN \
apk add --no-cache make bash ;\
echo -e "#"'!'"/usr/bin/env bash\n\nmake -f /opt/terraform/Makefile "'$'"@" > /usr/bin/tf-make ;\
chmod +x /usr/bin/tf-make

WORKDIR /opt/terraform
COPY . .

VOLUME [ /opt/terraform/providers ]
VOLUME [ /opt/terraform/modules ]

ENTRYPOINT [ "/usr/bin/tf-make" ]

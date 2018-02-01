FROM hashicorp/terraform:0.11.3

RUN \
apk add --no-cache make bash ca-certificates jq curl ruby ruby-json;\
echo -e "#"'!'"/usr/bin/env bash\n\nmake -f /opt/terraform/Makefile "'$'"@" > /usr/bin/tf-make ;\
chmod +x /usr/bin/tf-make ;\
gem install --no-rdoc --no-ri terraform_landscape 

WORKDIR /opt/terraform
ADD . .

VOLUME [ /opt/terraform/providers ]
VOLUME [ /opt/terraform/modules ]

ENTRYPOINT [ "/usr/bin/tf-make" ]

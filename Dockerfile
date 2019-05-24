FROM hashicorp/terraform:0.12.0

RUN \
apk add --no-cache make bash ca-certificates jq curl ruby ruby-json;\
apk add --no-cache -t build gcc ruby-dev libc-dev ;\
echo -e "#"'!'"/usr/bin/env bash\n\nmake -f /opt/terraform/Makefile "'$'"@" > /usr/bin/tf-make ;\
chmod +x /usr/bin/tf-make ;\
gem install --no-rdoc --no-ri terraform_landscape ;\
apk del --purge build

WORKDIR /opt/terraform
ADD . .

VOLUME [ /opt/terraform/providers ]
VOLUME [ /opt/terraform/modules ]

ENTRYPOINT [ "/usr/bin/tf-make" ]

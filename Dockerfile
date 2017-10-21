FROM hashicorp/terraform:0.10.7

RUN \
apk add --no-cache make bash ;\
echo 'tf-make() { make -f /opt/terraform/Makefile $@ ; }' >> /etc/profile

WORKDIR /opt/terraform
COPY . .

VOLUME [ /opt/terraform/providers ]
VOLUME [ /opt/terraform/modules ]

ENTRYPOINT [ "/bin/bash", "-l" ]

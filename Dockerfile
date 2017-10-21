FROM hashicorp/terraform:0.10.7

RUN \
apk add --no-cache make bash ;\
echo 'alias tf-make="make -f /opt/terraform/Makefile"' >> ~/.bashrc ;\
echo 'alias tf-make="make -f /opt/terraform/Makefile"' >> /etc/profile

WORKDIR /opt/terraform
COPY . .

VOLUME [ /opt/terraform/providers ]
VOLUME [ /opt/terraform/modules ]

ENTRYPOINT [ "/bin/sh", "-l" ]

FROM ubuntu:bionic-20200403

ENV BIND_USER=bind \
    BIND_VERSION=9.11.3 \
    DATA_DIR=/data

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      bind9=1:${BIND_VERSION}* bind9utils=1:${BIND_VERSION}* dnsutils\
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh

COPY create-key.sh /opt/create-key.sh

RUN chmod 755 /sbin/entrypoint.sh /opt/create-key.sh

EXPOSE 53/udp 53/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/named"]
FROM ubuntu:18.04 AS build

RUN mkdir -p /conf
RUN apt-get update
RUN apt-get install -y \
  build-essential \
  gpg \
  curl \
  libgmp-dev \
  iptables \
  module-init-tools \
  libssl-dev \
  tree

ENV STRONGSWAN_VERSION 5.8.2
ENV GPG_KEY 948F158A4E76A27BF3D07532DF42C170B34DBA77

RUN mkdir -p /usr/src/strongswan \
  && cd /usr/src \
  && curl -SOL "https://download.strongswan.org/strongswan-$STRONGSWAN_VERSION.tar.gz.sig" \
  && curl -SOL "https://download.strongswan.org/strongswan-$STRONGSWAN_VERSION.tar.gz" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
  && gpg --batch --verify strongswan-$STRONGSWAN_VERSION.tar.gz.sig strongswan-$STRONGSWAN_VERSION.tar.gz \
  && tar -zxf strongswan-$STRONGSWAN_VERSION.tar.gz -C /usr/src/strongswan --strip-components 1 \
  && cd /usr/src/strongswan \
  && ./configure --prefix=/usr --sysconfdir=/etc \
    --enable-eap-radius \
    --enable-eap-mschapv2 \
    --enable-eap-identity \
    --enable-eap-md5 \
    --enable-eap-tls \
    --enable-eap-ttls \
    --enable-eap-peap \
    --enable-eap-tnc \
    --enable-eap-dynamic \
    --enable-xauth-eap \
    --enable-openssl \
  && make -j \
  && make install DESTDIR=/tmp/strongswan \
  && tree /tmp/strongswan

FROM ubuntu:18.04
COPY --from=build /var/lib/apt/ /var/lib/apt/
COPY --from=build /tmp/strongswan /
RUN apt-get install -y openssl iproute2 net-tools ipcalc && rm -fr /var/lib/apt/lists
ENTRYPOINT ["/usr/sbin/ipsec"]
CMD ["start", "--nofork"]

FROM alpine:edge as builder

LABEL maintainer="wells <wellsgz@wellsgz.io>"

ENV SNELL_VERSION v2.0.1

RUN apk update \
  && apk add --no-cache \
    unzip \
    upx \
  && wget -O snell-server.zip https://github.com/surge-networks/snell/releases/download/${SNELL_VERSION}/snell-server-${SNELL_VERSION}-linux-amd64.zip \
  && unzip snell-server.zip \
  && upx --brute snell-server \
  && mv snell-server /usr/local/bin/


FROM alpine:3.9

LABEL maintainer="wells <wellsgz@wellsgz.io>"

ENV GLIBC_VERSION 2.31-r0

ENV SERVER_HOST 0.0.0.0
ENV SERVER_PORT=
ENV PSK=
ENV OBFS=
ENV ARGS=

COPY --from=builder /usr/local/bin /usr/local/bin

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
  && wget -O glibc.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
  && wget -O glibc-bin.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk \
  && apk add glibc.apk glibc-bin.apk \
  && apk add --no-cache libstdc++ \
  && rm -rf glibc.apk glibc-bin.apk /etc/apk/keys/sgerrand.rsa.pub /var/cache/apk/*

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

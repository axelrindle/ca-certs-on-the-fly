FROM alpine:3 AS setup

RUN apk add --no-cache \
        git \
        make \
        python3 \
        py3-cryptography && \
    apk del --no-cache \
        ca-certificates

RUN git clone https://salsa.debian.org/debian/ca-certificates.git /usr/local/src/ca-certificates

WORKDIR /usr/local/src/ca-certificates

ARG GIT_COMMIT="ba3830faf6207f6444827209915dcfc4ce44b272"

RUN git checkout "${GIT_COMMIT}" && \
    make && \
    make install DESTDIR=""


FROM alpine:3

COPY --from=setup /usr/sbin/update-ca-certificates /usr/sbin/update-ca-certificates
COPY --from=setup /usr/share/ca-certificates/mozilla/ /usr/local/share/ca-certificates/mozilla/

COPY rootfs /

RUN apk add --no-cache \
        openssl \
        run-parts \
    && \
    touch /etc/ca-certificates.conf && \
    mkdir -p /etc/ca-certificates/update.d

CMD [ "sh", "/docker-entrypoint.sh" ]

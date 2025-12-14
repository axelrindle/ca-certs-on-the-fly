FROM alpine:3 AS setup

ADD https://salsa.debian.org/debian/ca-certificates.git?commit=ba3830faf6207f6444827209915dcfc4ce44b272 /usr/local/src/ca-certificates

RUN apk add --no-cache \
        make \
        python3 \
        py3-cryptography && \
    apk del --no-cache \
        ca-certificates

WORKDIR /usr/local/src/ca-certificates

RUN make && \
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

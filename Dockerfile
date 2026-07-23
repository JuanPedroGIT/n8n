FROM python:3.11-alpine AS builder
RUN apk add --no-cache postgresql-client

FROM n8nio/n8n:latest
USER root
COPY --from=builder /usr/local/bin/python3 /usr/local/bin/python3
COPY --from=builder /usr/local/bin/pip3 /usr/local/bin/pip3
COPY --from=builder /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=builder /usr/bin/pg_dump /usr/local/bin/pg_dump
COPY --from=builder /usr/lib/libpq.so.5 /usr/local/lib/libpq.so.5
COPY --from=builder /usr/lib/libpq.so.5.17 /usr/local/lib/libpq.so.5.17
COPY --from=builder /usr/lib/liblz4.so.1 /usr/lib/liblz4.so.1
COPY --from=builder /usr/lib/liblz4.so.1.10.0 /usr/lib/liblz4.so.1.10.0
COPY --from=builder /usr/lib/libldap.so.2 /usr/lib/libldap.so.2
COPY --from=builder /usr/lib/libldap.so.2.0.200 /usr/lib/libldap.so.2.0.200
COPY --from=builder /usr/lib/libgssapi_krb5.so.2 /usr/lib/libgssapi_krb5.so.2
COPY --from=builder /usr/lib/libgssapi_krb5.so.2.2 /usr/lib/libgssapi_krb5.so.2.2
COPY --from=builder /usr/lib/libsasl2.so.3 /usr/lib/libsasl2.so.3
COPY --from=builder /usr/lib/libsasl2.so.3.0.0 /usr/lib/libsasl2.so.3.0.0
COPY --from=builder /usr/lib/libkrb5.so.3 /usr/lib/libkrb5.so.3
COPY --from=builder /usr/lib/libkrb5.so.3.3 /usr/lib/libkrb5.so.3.3
COPY --from=builder /usr/lib/libkrb5support.so.0 /usr/lib/libkrb5support.so.0
COPY --from=builder /usr/lib/libkrb5support.so.0.1 /usr/lib/libkrb5support.so.0.1
COPY --from=builder /usr/lib/libcom_err.so.2 /usr/lib/libcom_err.so.2
COPY --from=builder /usr/lib/libcom_err.so.2.1 /usr/lib/libcom_err.so.2.1
RUN ln -sf /usr/local/bin/python3 /usr/bin/python3
USER node

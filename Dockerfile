FROM python:3.11-alpine AS builder
RUN apk add --no-cache postgresql-client

FROM n8nio/n8n:latest
USER root
COPY --from=builder /usr/local/bin/python3 /usr/local/bin/python3
COPY --from=builder /usr/local/bin/pip3 /usr/local/bin/pip3
COPY --from=builder /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=builder /usr/bin/pg_dump /usr/local/bin/pg_dump
COPY --from=builder /usr/lib/libpq.so.5 /usr/local/lib/libpq.so.5
COPY --from=builder /usr/lib/libpq.so.5.18 /usr/local/lib/libpq.so.5.18
COPY --from=builder /usr/lib/liblz4.so.1 /usr/lib/liblz4.so.1
COPY --from=builder /usr/lib/liblz4.so.1.10.0 /usr/lib/liblz4.so.1.10.0
RUN ln -sf /usr/local/bin/python3 /usr/bin/python3
USER node

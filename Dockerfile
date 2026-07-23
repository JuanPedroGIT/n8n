FROM python:3.11-alpine AS python-stage

FROM postgres:16-alpine AS pg-stage

FROM n8nio/n8n:latest
USER root
COPY --from=python-stage /usr/local/bin/python3 /usr/local/bin/python3
COPY --from=python-stage /usr/local/bin/pip3 /usr/local/bin/pip3
COPY --from=python-stage /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=pg-stage /usr/local/bin/pg_dump /usr/local/bin/pg_dump
COPY --from=pg-stage /usr/local/lib /usr/local/lib
RUN ln -sf /usr/local/bin/python3 /usr/bin/python3
USER node

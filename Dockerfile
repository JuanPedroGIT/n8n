FROM n8nio/n8n:latest

USER root

# Instala Python compatible con Alpine (n8n v1+) o Debian (versiones antiguas)
RUN if command -v apk > /dev/null 2>&1; then \
      apk add --no-cache python3 py3-pip; \
    else \
      apt-get update && apt-get install -y --no-install-recommends python3 python3-pip && \
      apt-get clean && rm -rf /var/lib/apt/lists/*; \
    fi

USER node

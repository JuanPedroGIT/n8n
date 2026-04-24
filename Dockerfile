FROM n8nio/n8n:latest-debian

# Instalar Python 3 y pip (Debian/Ubuntu usa apt-get)
USER root
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Volver al usuario node
USER node

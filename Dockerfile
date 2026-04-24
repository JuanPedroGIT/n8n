# Usa la imagen oficial más reciente de n8n
FROM n8nio/n8n

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /home/node/

# El puerto 5678 es el puerto por defecto que usa n8n
EXPOSE 5678

# El comando por defecto de la imagen ya inicia n8n, 
# pero puedes especificarlo si lo necesitas para un control exacto
CMD ["n8n", "start"]
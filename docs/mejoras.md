# Mejoras pendientes n8n

## Dar acceso Docker al contenedor n8n

Actualmente el contenedor n8n no tiene el CLI de Docker ni el socket. Para backups y otras tareas usa `pg_dump` directo, copiado con multi-stage build.

**Mejora propuesta:** montar el socket de Docker y añadir el binario `docker`.

### Cambios necesarios

**Dockerfile:**
```dockerfile
FROM docker:cli AS docker-stage

FROM n8nio/n8n:latest
USER root
COPY --from=docker-stage /usr/local/bin/docker /usr/local/bin/docker
# ... resto igual ...
```

**docker-compose.yml:**
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

### Ventajas
- Ejecutar `docker exec` en cualquier contenedor desde n8n
- No hace falta copiar binarios ni librerías de otros contenedores
- Útil para cualquier automatización futura (no solo backups)

### Riesgos
- El contenedor n8n tendría acceso total al socket Docker = acceso root al host
- Mitigación: usar un proxy de socket (ej. `docker-socket-proxy`) que limite los endpoints expuestos

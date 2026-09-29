# ============================================================
# Makefile - n8n (dulziasalamanca.es)
# Uso: make <target>            (ver `make help`)
# Pensado para ejecutarse en el servidor Ubuntu donde corre Docker.
# ============================================================

COMPOSE        ?= docker compose
SERVICE        ?= n8n
PG_HOST        ?= shared-postgres-db

# --- Backup ---
BACKUP_DB      ?= cokalba_running
BACKUP_USER    ?= cokalba
BACKUP_PASS    ?=          # OBLIGATORIO: make backup BACKUP_PASS=secret
BACKUP_DIR     ?= /backups # ruta DENTRO del contenedor n8n (monta /home/ubuntu/apps/backups)
BACKUP_PREFIX  ?= backup_cokalbarunning
RETENTION_DAYS ?= 7

.DEFAULT_GOAL := help

.PHONY: help prod-up prod-down prod-restart prod-logs prod-ps prod-shell \
        build prod-deploy update db-init backup backup-cleanup restore check clean

## Muestra esta ayuda
help:
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-16s %s\n", $$1, $$2}'

## Levanta el stack en background (sin rebuild)
prod-up:
	$(COMPOSE) up -d

## Para el stack (conserva datos)
prod-down:
	$(COMPOSE) down

## Reinicia el contenedor n8n
prod-restart:
	$(COMPOSE) restart $(SERVICE)

## Sigue los logs de n8n (Ctrl+C para salir)
prod-logs:
	$(COMPOSE) logs -f --tail=200 $(SERVICE)

## Estado de los contenedores
prod-ps:
	$(COMPOSE) ps

## Abre una shell bash dentro del contenedor n8n
prod-shell:
	$(COMPOSE) exec $(SERVICE) bash

## Rebuild de la imagen (multi-stage: python + pg_dump)
build:
	$(COMPOSE) build --no-cache $(SERVICE)

## Rebuild + despliegue en background
prod-deploy: build
	$(COMPOSE) up -d

## Actualiza la imagen base n8nio/n8n y redespliega
update:
	docker pull n8nio/n8n:latest
	$(COMPOSE) build $(SERVICE)
	$(COMPOSE) up -d

## Crea el usuario y la BD 'n8n' en el Postgres compartido (requiere psql en el host)
db-init:
	@test -x ./init-db.sh || { echo "Error: no se encuentra init-db.sh"; exit 1; }
	./init-db.sh

## Backup manual de la BD (pg_dump + gzip dentro del contenedor n8n)
backup:
	@test -n "$(BACKUP_PASS)" || { echo "Error: BACKUP_PASS es obligatorio. Ej: make backup BACKUP_PASS=secret"; exit 1; }
	$(COMPOSE) exec -T $(SERVICE) sh -c \
		'PGPASSWORD=$(BACKUP_PASS) pg_dump -h $(PG_HOST) -U $(BACKUP_USER) $(BACKUP_DB) | gzip > $(BACKUP_DIR)/$(BACKUP_PREFIX)_$$(date +%Y%m%d_%H%M%S).sql.gz && echo "OK: backup creado"'

## Elimina backups de más de $(RETENTION_DAYS) días (en $(BACKUP_DIR))
backup-cleanup:
	$(COMPOSE) exec -T $(SERVICE) sh -c \
		'find $(BACKUP_DIR) -name "$(BACKUP_PREFIX)_*.sql.gz" -mtime +$(RETENTION_DAYS) -delete -print'

## Restaura un backup: make restore FILE=backups/xxx.sql.gz BACKUP_PASS=secret (¡DESTRUCTIVO!)
restore:
	@test -n "$(FILE)" || { echo "Error: FILE es obligatorio. Ej: make restore FILE=backups/xxx.sql.gz BACKUP_PASS=secret"; exit 1; }
	@test -n "$(BACKUP_PASS)" || { echo "Error: BACKUP_PASS es obligatorio."; exit 1; }
	@test -f "$(FILE)" || { echo "Error: no existe $(FILE)"; exit 1; }
	@echo "ATENCION: se va a SOBREESCRIBIR la BD $(BACKUP_DB). Ctrl+C para cancelar."
	gunzip -c "$(FILE)" | docker exec -i $(PG_HOST) sh -c \
		'PGPASSWORD=$(BACKUP_PASS) psql -U $(BACKUP_USER) -d $(BACKUP_DB)'

## Valida la configuracion de docker-compose
check:
	$(COMPOSE) config --quiet && echo "Config OK"
	$(COMPOSE) ps

## Para el stack y borra el volumen n8n_data (¡DESTRUYE LOS DATOS DE n8n!)
clean:
	@echo "ATENCION: se va a borrar el volumen n8n_data. Ctrl+C para cancelar."
	$(COMPOSE) down -v

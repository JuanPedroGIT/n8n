#!/bin/bash
set -e

HOST="${POSTGRES_HOST:-shared-postgres-db}"
SUPERUSER="${POSTGRES_USER:-postgres}"
PASS="${N8N_DB_PASS:-n8n_pass}"

until PGPASSWORD="$POSTGRES_PASSWORD" pg_isready -h "$HOST" -U "$SUPERUSER" -q; do
  echo "Waiting for postgres..."
  sleep 2
done

PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$HOST" -U "$SUPERUSER" -d postgres <<-EOSQL
	DO \$\$ BEGIN
	  CREATE USER n8n WITH ENCRYPTED PASSWORD '$PASS';
	EXCEPTION WHEN duplicate_object THEN NULL;
	END \$\$;

	SELECT 'CREATE DATABASE n8n OWNER n8n'
	WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'n8n')\gexec

	GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;
EOSQL

PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$HOST" -U "$SUPERUSER" -d n8n \
  -c "GRANT ALL ON SCHEMA public TO n8n;"

echo "n8n database ready."

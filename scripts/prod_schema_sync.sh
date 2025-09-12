#!/usr/bin/env bash
set -euo pipefail

# Prod-only schema sync for MariaDB (no data), then Alembic stamp to HEAD
# - Applies a SQL schema dump to prod DB with safe FK handling
# - Normalizes collation to utf8mb4_unicode_ci on-the-fly
# - Stamps Alembic heads for Backend and RAG prod services

SCHEMA_FILE="${1:-schema.sql}"
PROFILE="prod"
COMPOSE_FILE="docker-compose.full.yml"
# Fixed project name for stable container names
PROJECT_NAME="coe-prod"
DB_SERVICE="mariadb-prod"
BACKEND_SERVICE="coe-backend-prod"
RAG_SERVICE="coe-ragpipeline-prod"

# Set USE_SUDO=1 to prefix docker commands with sudo
SUDO_PREFIX=""
if [[ "${USE_SUDO:-0}" == "1" ]]; then
  SUDO_PREFIX="sudo"
fi

DC=( ${SUDO_PREFIX} docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" --profile "${PROFILE}" )

echo "[prod-schema-sync] Using schema file: ${SCHEMA_FILE}"
if [[ ! -f "${SCHEMA_FILE}" ]]; then
  echo "[prod-schema-sync] ERROR: schema file not found: ${SCHEMA_FILE}" >&2
  exit 1
fi

echo "[prod-schema-sync] Ensuring prod DB is up (${DB_SERVICE})..."
"${DC[@]}" up -d "${DB_SERVICE}"

echo "[prod-schema-sync] Waiting for MariaDB to become healthy..."
for i in $(seq 1 120); do
  if "${DC[@]}" exec -T "${DB_SERVICE}" sh -lc 'mariadb-admin -h127.0.0.1 -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" --silent ping' >/dev/null 2>&1; then
    echo "[prod-schema-sync] MariaDB is ready."
    break
  fi;
  sleep 1;
  if [[ $i -eq 120 ]]; then
    echo "[prod-schema-sync] ERROR: MariaDB did not become ready in time" >&2
    exit 1
  fi
done

echo "[prod-schema-sync] Pre-conditioning parent table (langflows) for FK integrity..."
# 1) Ensure table and column are present/normalized (idempotent)
"${DC[@]}" exec -T "${DB_SERVICE}" sh -lc 'mariadb -h127.0.0.1 -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE"' <<'SQL'
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;
CREATE TABLE IF NOT EXISTS `langflows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `flow_id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `flow_data` longtext,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_langflows_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
ALTER TABLE `langflows` MODIFY `flow_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL;
SQL

# 2) Add unique index on flow_id only if missing (avoid duplicate key error)
"${DC[@]}" exec -T "${DB_SERVICE}" sh -lc 'mariadb -h127.0.0.1 -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE"' <<'SQL'
SET @exists := (
  SELECT COUNT(1)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'langflows'
    AND index_name = 'ix_langflows_flow_id'
);
SET @sql := IF(@exists = 0, 'ALTER TABLE langflows ADD UNIQUE KEY ix_langflows_flow_id (flow_id);', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SQL

echo "[prod-schema-sync] Importing schema (FK off, collation normalize -> utf8mb4_unicode_ci)..."
(
  echo 'SET NAMES utf8mb4;';
  echo 'SET FOREIGN_KEY_CHECKS=0;';
  sed 's/utf8mb4_uca1400_ai_ci/utf8mb4_unicode_ci/g' "${SCHEMA_FILE}"
) | "${DC[@]}" exec -T "${DB_SERVICE}" sh -lc '
  mariadb -h127.0.0.1 -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE" --force'

echo "[prod-schema-sync] Alembic stamp HEAD (backend)..."
"${DC[@]}" exec -T "${BACKEND_SERVICE}" alembic stamp head || {
  echo "[prod-schema-sync] Backend container not ready for exec; trying one-off run..."
  "${DC[@]}" run --rm "${BACKEND_SERVICE}" alembic stamp head
}

echo "[prod-schema-sync] Alembic stamp HEAD (rag)..."
"${DC[@]}" exec -T "${RAG_SERVICE}" alembic stamp head || {
  echo "[prod-schema-sync] RAG container not ready for exec; trying one-off run..."
  "${DC[@]}" run --rm "${RAG_SERVICE}" alembic stamp head
}

echo "[prod-schema-sync] Verify alembic versions..."
"${DC[@]}" exec -T "${DB_SERVICE}" sh -lc '
  mariadb -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" -e \
  "SELECT * FROM alembic_version_backend; SELECT * FROM alembic_version_rag;" "$MARIADB_DATABASE" || true'

echo "[prod-schema-sync] Done."


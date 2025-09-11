#!/usr/bin/env bash
set -euo pipefail

# Dev-only schema sync for MariaDB (no data), then Alembic stamp to HEAD
# - Applies a SQL schema dump to dev DB with safe FK handling
# - Normalizes collation to utf8mb4_unicode_ci on-the-fly
# - Stamps Alembic heads for Backend and RAG dev services

SCHEMA_FILE="${1:-schema.sql}"
PROFILE="dev"
COMPOSE_FILE="docker-compose.full.yml"
DB_SERVICE="mariadb-dev"
BACKEND_SERVICE="coe-backend-dev"
RAG_SERVICE="coe-ragpipeline-dev"

# Set USE_SUDO=1 to prefix docker commands with sudo
SUDO_PREFIX=""
if [[ "${USE_SUDO:-0}" == "1" ]]; then
  SUDO_PREFIX="sudo"
fi

DC=( ${SUDO_PREFIX} docker compose -f "${COMPOSE_FILE}" --profile "${PROFILE}" )

echo "[dev-schema-sync] Using schema file: ${SCHEMA_FILE}"
if [[ ! -f "${SCHEMA_FILE}" ]]; then
  echo "[dev-schema-sync] ERROR: schema file not found: ${SCHEMA_FILE}" >&2
  exit 1
fi

echo "[dev-schema-sync] Ensuring dev DB is up (${DB_SERVICE})..."
"${DC[@]}" up -d "${DB_SERVICE}"

echo "[dev-schema-sync] Pre-conditioning parent table (langflows) for FK integrity..."
"${DC[@]}" exec -T "${DB_SERVICE}" sh -lc '
  mariadb -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE" <<"SQL"
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
  UNIQUE KEY `ix_langflows_flow_id` (`flow_id`),
  KEY `ix_langflows_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
ALTER TABLE `langflows` MODIFY `flow_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `langflows` ADD UNIQUE KEY `ix_langflows_flow_id` (`flow_id`);
SQL
'

echo "[dev-schema-sync] Importing schema (FK off, collation normalize -> utf8mb4_unicode_ci)..."
(
  echo 'SET NAMES utf8mb4;';
  echo 'SET FOREIGN_KEY_CHECKS=0;';
  sed 's/utf8mb4_uca1400_ai_ci/utf8mb4_unicode_ci/g' "${SCHEMA_FILE}"
) | "${DC[@]}" exec -T "${DB_SERVICE}" sh -lc '
  mariadb -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE" --force'

echo "[dev-schema-sync] Alembic stamp HEAD (backend)..."
"${DC[@]}" exec -T "${BACKEND_SERVICE}" alembic stamp head || {
  echo "[dev-schema-sync] Backend container not ready for exec; trying one-off run..."
  "${DC[@]}" run --rm "${BACKEND_SERVICE}" alembic stamp head
}

echo "[dev-schema-sync] Alembic stamp HEAD (rag)..."
"${DC[@]}" exec -T "${RAG_SERVICE}" alembic stamp head || {
  echo "[dev-schema-sync] RAG container not ready for exec; trying one-off run..."
  "${DC[@]}" run --rm "${RAG_SERVICE}" alembic stamp head
}

echo "[dev-schema-sync] Verify alembic versions..."
"${DC[@]}" exec -T "${DB_SERVICE}" sh -lc '
  mariadb -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" -e \
  "SELECT * FROM alembic_version_backend; SELECT * FROM alembic_version_rag;" "$MARIADB_DATABASE" || true'

echo "[dev-schema-sync] Done."


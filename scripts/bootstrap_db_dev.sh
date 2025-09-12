#!/usr/bin/env bash
set -euo pipefail

# Bootstrap core DB tables for dev profile (coe-dev)
# Creates analysis_requests and repository_analyses if missing.

COMPOSE="docker compose -f docker-compose.full.yml -p coe-dev"
DB_SVC="mariadb-dev"
DB="coe_db"
ROOT_USER="root"
ROOT_PW="acce"

echo "[db-bootstrap] Creating base tables in ${DB} if missing..."
$COMPOSE exec -T "$DB_SVC" sh -lc "mariadb -u${ROOT_USER} -p${ROOT_PW} ${DB} <<'SQL'
CREATE TABLE IF NOT EXISTS analysis_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  analysis_id VARCHAR(255) NOT NULL,
  status VARCHAR(50) NOT NULL,
  repositories LONGTEXT,
  include_ast TINYINT(1) NOT NULL,
  include_tech_spec TINYINT(1) NOT NULL,
  include_correlation TINYINT(1) NOT NULL,
  group_name VARCHAR(255),
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  completed_at DATETIME NULL,
  error_message TEXT NULL,
  UNIQUE KEY analysis_id (analysis_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS repository_analyses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  analysis_id VARCHAR(36) NOT NULL,
  repository_url VARCHAR(500) NOT NULL,
  repository_name VARCHAR(255),
  branch VARCHAR(100) DEFAULT 'main',
  clone_path VARCHAR(500),
  status VARCHAR(50) DEFAULT 'PENDING',
  commit_hash VARCHAR(40),
  commit_date DATETIME,
  commit_author VARCHAR(255),
  commit_message MEDIUMTEXT,
  files_count INT DEFAULT 0,
  lines_of_code INT DEFAULT 0,
  languages LONGTEXT,
  frameworks LONGTEXT,
  dependencies LONGTEXT,
  ast_data MEDIUMTEXT,
  tech_specs LONGTEXT,
  code_metrics LONGTEXT,
  documentation_files LONGTEXT,
  config_files LONGTEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT repository_analyses_ibfk_1 FOREIGN KEY (analysis_id) REFERENCES analysis_requests (analysis_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_repository_url ON repository_analyses (repository_url);
CREATE INDEX IF NOT EXISTS idx_repo_analysis_id ON repository_analyses (analysis_id);
CREATE INDEX IF NOT EXISTS idx_commit_hash ON repository_analyses (commit_hash);
SQL"

echo "[db-bootstrap] Done. Showing tables:"
$COMPOSE exec -T "$DB_SVC" mariadb -u${ROOT_USER} -p${ROOT_PW} -D ${DB} -e "SHOW TABLES LIKE 'analysis_requests'; SHOW TABLES LIKE 'repository_analyses';"


-- Create analysis_requests table
CREATE TABLE IF NOT EXISTS analysis_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    analysis_id VARCHAR(255) UNIQUE NOT NULL,
    status VARCHAR(50) NOT NULL,
    repositories JSON,
    include_ast BOOLEAN NOT NULL,
    include_tech_spec BOOLEAN NOT NULL,
    include_correlation BOOLEAN NOT NULL,
    group_name VARCHAR(255),
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    completed_at DATETIME,
    error_message TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create conversation_summaries table
CREATE TABLE IF NOT EXISTS conversation_summaries (
    conversation_id VARCHAR(255) PRIMARY KEY,
    summary TEXT NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    group_name VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create schema_migrations table (if not already created by 01_create_database.sql or migrate.py)
CREATE TABLE IF NOT EXISTS schema_migrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    version VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    executed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_version (version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create rag_analysis_results table
CREATE TABLE IF NOT EXISTS rag_analysis_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    analysis_id VARCHAR(255) UNIQUE NOT NULL,
    git_url VARCHAR(500) NOT NULL,
    analysis_date DATETIME NOT NULL,
    status VARCHAR(50) NOT NULL,
    repository_count INT DEFAULT 0,
    total_files INT DEFAULT 0,
    total_lines_of_code INT DEFAULT 0,
    repositories_data MEDIUMTEXT,
    correlation_data MEDIUMTEXT,
    tech_specs_summary MEDIUMTEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    error_message TEXT,
    INDEX idx_analysis_id (analysis_id),
    INDEX idx_git_url (git_url)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create repository_analyses table
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
    languages JSON,
    frameworks JSON,
    dependencies JSON,
    ast_data MEDIUMTEXT,
    tech_specs JSON,
    code_metrics JSON,
    documentation_files JSON,
    config_files JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (analysis_id) REFERENCES analysis_requests(analysis_id),
    INDEX idx_repo_analysis_id (analysis_id),
    INDEX idx_repository_url (repository_url),
    INDEX idx_commit_hash (commit_hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Alter rag_analysis_results table to change column types to MEDIUMTEXT
ALTER TABLE rag_analysis_results
MODIFY COLUMN repositories_data MEDIUMTEXT,
MODIFY COLUMN correlation_data MEDIUMTEXT,
MODIFY COLUMN tech_specs_summary MEDIUMTEXT;

-- Alter repository_analyses table to change column types to MEDIUMTEXT
ALTER TABLE repository_analyses
MODIFY COLUMN commit_message MEDIUMTEXT,
MODIFY COLUMN ast_data MEDIUMTEXT;
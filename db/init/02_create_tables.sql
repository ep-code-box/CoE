-- CoE 프로젝트 테이블 생성 스크립트
-- MariaDB/MySQL용

USE coe_db;

-- LangFlow 테이블
CREATE TABLE IF NOT EXISTS langflows (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    flow_data TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_name (name),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 분석 요청 테이블
CREATE TABLE IF NOT EXISTS analysis_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    analysis_id VARCHAR(36) UNIQUE NOT NULL,
    status ENUM('PENDING', 'RUNNING', 'COMPLETED', 'FAILED') DEFAULT 'PENDING',
    repositories JSON NOT NULL,
    include_ast BOOLEAN DEFAULT TRUE,
    include_tech_spec BOOLEAN DEFAULT TRUE,
    include_correlation BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at DATETIME NULL,
    error_message TEXT NULL,
    INDEX idx_analysis_id (analysis_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 레포지토리 분석 결과 테이블
CREATE TABLE IF NOT EXISTS repository_analyses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    analysis_id VARCHAR(36) NOT NULL,
    repository_url VARCHAR(500) NOT NULL,
    repository_name VARCHAR(255),
    branch VARCHAR(100) DEFAULT 'main',
    clone_path VARCHAR(500),
    status ENUM('PENDING', 'CLONING', 'ANALYZING', 'COMPLETED', 'FAILED') DEFAULT 'PENDING',
    files_count INT DEFAULT 0,
    lines_of_code INT DEFAULT 0,
    languages JSON,
    frameworks JSON,
    dependencies JSON,
    ast_data TEXT,
    tech_specs JSON,
    code_metrics JSON,
    documentation_files JSON,
    config_files JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (analysis_id) REFERENCES analysis_requests(analysis_id) ON DELETE CASCADE,
    INDEX idx_analysis_id (analysis_id),
    INDEX idx_repository_url (repository_url),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 코드 파일 정보 테이블
CREATE TABLE IF NOT EXISTS code_files (
    id INT AUTO_INCREMENT PRIMARY KEY,
    repository_analysis_id INT NOT NULL,
    file_path VARCHAR(1000) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_size INT DEFAULT 0,
    language VARCHAR(50),
    lines_of_code INT DEFAULT 0,
    complexity_score DECIMAL(5,2),
    last_modified DATETIME,
    file_hash VARCHAR(64),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (repository_analysis_id) REFERENCES repository_analyses(id) ON DELETE CASCADE,
    INDEX idx_repository_analysis_id (repository_analysis_id),
    INDEX idx_language (language),
    INDEX idx_file_name (file_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- AST 노드 테이블
CREATE TABLE IF NOT EXISTS ast_nodes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code_file_id INT NOT NULL,
    node_type VARCHAR(100) NOT NULL,
    node_name VARCHAR(255),
    line_start INT,
    line_end INT,
    parent_id INT,
    node_metadata JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (code_file_id) REFERENCES code_files(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES ast_nodes(id) ON DELETE SET NULL,
    INDEX idx_code_file_id (code_file_id),
    INDEX idx_node_type (node_type),
    INDEX idx_parent_id (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 기술 스택 및 의존성 테이블
CREATE TABLE IF NOT EXISTS tech_dependencies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    repository_analysis_id INT NOT NULL,
    dependency_type ENUM('FRAMEWORK', 'LIBRARY', 'TOOL', 'LANGUAGE') NOT NULL,
    name VARCHAR(255) NOT NULL,
    version VARCHAR(100),
    package_manager VARCHAR(50),
    is_dev_dependency BOOLEAN DEFAULT FALSE,
    license VARCHAR(100),
    vulnerability_count INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (repository_analysis_id) REFERENCES repository_analyses(id) ON DELETE CASCADE,
    INDEX idx_repository_analysis_id (repository_analysis_id),
    INDEX idx_dependency_type (dependency_type),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 레포지토리 간 연관도 분석 테이블
CREATE TABLE IF NOT EXISTS correlation_analyses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    analysis_id VARCHAR(36) NOT NULL,
    repository1_id INT NOT NULL,
    repository2_id INT NOT NULL,
    common_dependencies JSON,
    similar_patterns JSON,
    architecture_similarity DECIMAL(5,4) DEFAULT 0.0000,
    shared_technologies JSON,
    similarity_score DECIMAL(5,4) DEFAULT 0.0000,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (analysis_id) REFERENCES analysis_requests(analysis_id) ON DELETE CASCADE,
    FOREIGN KEY (repository1_id) REFERENCES repository_analyses(id) ON DELETE CASCADE,
    FOREIGN KEY (repository2_id) REFERENCES repository_analyses(id) ON DELETE CASCADE,
    INDEX idx_analysis_id (analysis_id),
    INDEX idx_repository1_id (repository1_id),
    INDEX idx_repository2_id (repository2_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 문서 분석 결과 테이블
CREATE TABLE IF NOT EXISTS document_analyses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    repository_analysis_id INT NOT NULL,
    document_path VARCHAR(1000) NOT NULL,
    document_type ENUM('README', 'API_DOC', 'WIKI', 'CHANGELOG', 'CONTRIBUTING', 'OTHER') DEFAULT 'OTHER',
    title VARCHAR(500),
    content TEXT,
    extracted_sections JSON,
    code_examples JSON,
    api_endpoints JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (repository_analysis_id) REFERENCES repository_analyses(id) ON DELETE CASCADE,
    INDEX idx_repository_analysis_id (repository_analysis_id),
    INDEX idx_document_type (document_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 벡터 임베딩 메타데이터 테이블
CREATE TABLE IF NOT EXISTS vector_embeddings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    source_type ENUM('CODE', 'DOCUMENT', 'AST_NODE') NOT NULL,
    source_id INT NOT NULL,
    chunk_id VARCHAR(100) NOT NULL,
    collection_name VARCHAR(255) NOT NULL,
    embedding_model VARCHAR(100) DEFAULT 'default',
    chunk_text TEXT,
    node_metadata JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_source_type (source_type),
    INDEX idx_source_id (source_id),
    INDEX idx_chunk_id (chunk_id),
    INDEX idx_collection_name (collection_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 개발 표준 문서 테이블
CREATE TABLE IF NOT EXISTS development_standards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    analysis_id VARCHAR(36) NOT NULL,
    standard_type ENUM('CODING_STYLE', 'ARCHITECTURE_PATTERN', 'COMMON_FUNCTIONS', 'BEST_PRACTICES') NOT NULL,
    title VARCHAR(500) NOT NULL,
    content TEXT NOT NULL,
    examples JSON,
    recommendations JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (analysis_id) REFERENCES analysis_requests(analysis_id) ON DELETE CASCADE,
    INDEX idx_analysis_id (analysis_id),
    INDEX idx_standard_type (standard_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- RAG 분석 결과 테이블 (백워드 호환성)
CREATE TABLE IF NOT EXISTS rag_analysis_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    analysis_id VARCHAR(255) UNIQUE NOT NULL,
    git_url VARCHAR(500) NOT NULL,
    analysis_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PENDING', 'RUNNING', 'COMPLETED', 'FAILED') DEFAULT 'PENDING',
    repository_count INT DEFAULT 0,
    total_files INT DEFAULT 0,
    total_lines_of_code INT DEFAULT 0,
    repositories_data TEXT,
    correlation_data TEXT,
    tech_specs_summary TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME NULL,
    error_message TEXT NULL,
    INDEX idx_analysis_id (analysis_id),
    INDEX idx_git_url (git_url),
    INDEX idx_status (status),
    INDEX idx_analysis_date (analysis_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 사용자 세션 테이블 (선택적)
CREATE TABLE IF NOT EXISTS user_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id VARCHAR(100) UNIQUE NOT NULL,
    user_agent TEXT,
    ip_address VARCHAR(45),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_activity DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_session_id (session_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- API 호출 로그 테이블 (선택적)
CREATE TABLE IF NOT EXISTS api_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id VARCHAR(100),
    endpoint VARCHAR(255) NOT NULL,
    method ENUM('GET', 'POST', 'PUT', 'DELETE', 'PATCH') NOT NULL,
    request_data JSON,
    response_status INT,
    response_time_ms INT,
    error_message TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES user_sessions(session_id) ON DELETE SET NULL,
    INDEX idx_session_id (session_id),
    INDEX idx_endpoint (endpoint),
    INDEX idx_method (method),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
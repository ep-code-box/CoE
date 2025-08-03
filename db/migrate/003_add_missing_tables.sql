-- CoE 프로젝트 누락된 테이블 마이그레이션
-- 버전: 003
-- 설명: 채팅 히스토리, 문서 생성 작업 추적, commit 정보 추가

-- 1. 채팅 메시지 히스토리 테이블
CREATE TABLE IF NOT EXISTS chat_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id VARCHAR(100) NOT NULL,
    user_id INT NULL,
    message_id VARCHAR(36) NOT NULL,
    role ENUM('user', 'assistant', 'system') NOT NULL,
    content TEXT NOT NULL,
    model_name VARCHAR(100),
    tokens_used INT DEFAULT 0,
    response_time_ms INT DEFAULT 0,
    metadata JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (session_id) REFERENCES user_sessions(session_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    
    INDEX idx_session_id (session_id),
    INDEX idx_user_id (user_id),
    INDEX idx_role (role),
    INDEX idx_created_at (created_at),
    INDEX idx_message_id (message_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. 대화 세션 요약 테이블
CREATE TABLE IF NOT EXISTS conversation_summaries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id VARCHAR(100) NOT NULL,
    user_id INT NULL,
    turn_count INT DEFAULT 0,
    summary TEXT,
    key_topics JSON,
    last_activity DATETIME DEFAULT CURRENT_TIMESTAMP,
    auto_summarized_at DATETIME NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (session_id) REFERENCES user_sessions(session_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    
    UNIQUE KEY unique_session (session_id),
    INDEX idx_user_id (user_id),
    INDEX idx_last_activity (last_activity),
    INDEX idx_turn_count (turn_count)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. 문서 생성 작업 추적 테이블
CREATE TABLE IF NOT EXISTS document_generation_tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id VARCHAR(36) UNIQUE NOT NULL,
    analysis_id VARCHAR(36) NOT NULL,
    status ENUM('PENDING', 'RUNNING', 'COMPLETED', 'FAILED') DEFAULT 'PENDING',
    document_types JSON NOT NULL,
    language VARCHAR(20) DEFAULT 'korean',
    custom_prompt TEXT,
    progress_percentage INT DEFAULT 0,
    current_document_type VARCHAR(50),
    total_documents INT DEFAULT 0,
    completed_documents INT DEFAULT 0,
    generated_documents JSON,
    error_message TEXT,
    tokens_used INT DEFAULT 0,
    processing_time_ms INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    started_at DATETIME NULL,
    completed_at DATETIME NULL,
    
    FOREIGN KEY (analysis_id) REFERENCES analysis_requests(analysis_id) ON DELETE CASCADE,
    
    INDEX idx_task_id (task_id),
    INDEX idx_analysis_id (analysis_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. 생성된 문서 파일 정보 테이블
CREATE TABLE IF NOT EXISTS generated_documents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id VARCHAR(36) NOT NULL,
    analysis_id VARCHAR(36) NOT NULL,
    document_type VARCHAR(50) NOT NULL,
    language VARCHAR(20) NOT NULL,
    file_path VARCHAR(1000) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_size INT DEFAULT 0,
    tokens_used INT DEFAULT 0,
    generation_time_ms INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (task_id) REFERENCES document_generation_tasks(task_id) ON DELETE CASCADE,
    FOREIGN KEY (analysis_id) REFERENCES analysis_requests(analysis_id) ON DELETE CASCADE,
    
    INDEX idx_task_id (task_id),
    INDEX idx_analysis_id (analysis_id),
    INDEX idx_document_type (document_type),
    INDEX idx_language (language)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. 시스템 설정 테이블
CREATE TABLE IF NOT EXISTS system_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type ENUM('STRING', 'INTEGER', 'BOOLEAN', 'JSON') DEFAULT 'STRING',
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_setting_key (setting_key),
    INDEX idx_is_public (is_public)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. repository_analyses 테이블에 commit 관련 컬럼 추가
ALTER TABLE repository_analyses 
ADD COLUMN IF NOT EXISTS commit_hash VARCHAR(40) NULL COMMENT 'Git commit hash (SHA-1)' AFTER clone_path,
ADD COLUMN IF NOT EXISTS commit_date DATETIME NULL COMMENT 'Commit 날짜' AFTER commit_hash,
ADD COLUMN IF NOT EXISTS commit_author VARCHAR(255) NULL COMMENT 'Commit 작성자' AFTER commit_date,
ADD COLUMN IF NOT EXISTS commit_message TEXT NULL COMMENT 'Commit 메시지' AFTER commit_author;

-- commit_hash에 인덱스 추가
ALTER TABLE repository_analyses 
ADD INDEX IF NOT EXISTS idx_commit_hash (commit_hash);

-- 마이그레이션 기록
INSERT INTO schema_migrations (version, description, checksum) 
VALUES ('003', 'Add missing tables for chat history and document generation', MD5('003_add_missing_tables.sql')) 
ON DUPLICATE KEY UPDATE applied_at = CURRENT_TIMESTAMP;
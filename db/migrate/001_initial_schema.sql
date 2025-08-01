-- CoE 프로젝트 초기 스키마 마이그레이션
-- 버전: 001
-- 설명: 초기 데이터베이스 스키마 생성

-- 마이그레이션 메타데이터 테이블 생성
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(20) PRIMARY KEY,
    description TEXT,
    applied_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    checksum VARCHAR(64)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 현재 마이그레이션 기록
INSERT INTO schema_migrations (version, description, checksum) 
VALUES ('001', 'Initial schema creation', 'initial') 
ON DUPLICATE KEY UPDATE applied_at = CURRENT_TIMESTAMP;

-- 기존 테이블들이 존재하지 않는 경우에만 생성
-- (실제 테이블 생성은 02_create_tables.sql에서 수행)
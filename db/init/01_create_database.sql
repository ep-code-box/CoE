-- CoE 프로젝트 데이터베이스 초기화 스크립트
-- MariaDB/MySQL용

-- 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS coe_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 사용자 생성 및 권한 부여
CREATE USER IF NOT EXISTS 'coe_user'@'%' IDENTIFIED BY 'coe_password';
GRANT ALL PRIVILEGES ON coe_db.* TO 'coe_user'@'%';
FLUSH PRIVILEGES;

-- 데이터베이스 사용
USE coe_db;
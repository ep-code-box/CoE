#!/usr/bin/env python3
"""
CoE 프로젝트 데이터베이스 마이그레이션 스크립트
"""

import os
import sys
import hashlib
from pathlib import Path
import pymysql
from dotenv import load_dotenv

# 환경 변수 로드
load_dotenv()

# 데이터베이스 연결 설정
DB_CONFIG = {
    'host': os.getenv("DB_HOST", "localhost"),
    'port': int(os.getenv("DB_PORT", "6667")),
    'user': os.getenv("DB_USER", "coe_user"),
    'password': os.getenv("DB_PASSWORD", "coe_password"),
    'database': os.getenv("DB_NAME", "coe_db"),
    'charset': 'utf8mb4'
}

def get_db_connection():
    """데이터베이스 연결을 반환합니다."""
    try:
        connection = pymysql.connect(**DB_CONFIG)
        return connection
    except Exception as e:
        print(f"❌ 데이터베이스 연결 실패: {e}")
        return None

def calculate_checksum(file_path):
    """파일의 MD5 체크섬을 계산합니다."""
    hash_md5 = hashlib.md5()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def get_applied_migrations(connection):
    """적용된 마이그레이션 목록을 반환합니다."""
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT version, checksum FROM schema_migrations ORDER BY version")
            return {row[0]: row[1] for row in cursor.fetchall()}
    except pymysql.Error:
        # schema_migrations 테이블이 없는 경우
        return {}

def apply_migration(connection, migration_file):
    """마이그레이션 파일을 적용합니다."""
    try:
        with open(migration_file, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # SQL 문을 세미콜론으로 분리하여 실행
        statements = [stmt.strip() for stmt in sql_content.split(';') if stmt.strip()]
        
        with connection.cursor() as cursor:
            for statement in statements:
                if statement:
                    cursor.execute(statement)
        
        connection.commit()
        return True
    except Exception as e:
        print(f"❌ 마이그레이션 적용 실패 ({migration_file}): {e}")
        connection.rollback()
        return False

def run_migrations():
    """마이그레이션을 실행합니다."""
    print("🚀 CoE 데이터베이스 마이그레이션 시작...")
    
    # 마이그레이션 디렉토리 확인
    migrate_dir = Path(__file__).parent
    migration_files = sorted(migrate_dir.glob("*.sql"))
    
    if not migration_files:
        print("📝 적용할 마이그레이션이 없습니다.")
        return True
    
    # 데이터베이스 연결
    connection = get_db_connection()
    if not connection:
        return False
    
    try:
        # 적용된 마이그레이션 확인
        applied_migrations = get_applied_migrations(connection)
        
        success_count = 0
        for migration_file in migration_files:
            version = migration_file.stem
            current_checksum = calculate_checksum(migration_file)
            
            if version in applied_migrations:
                if applied_migrations[version] == current_checksum:
                    print(f"✅ {version}: 이미 적용됨 (체크섬 일치)")
                    success_count += 1
                    continue
                else:
                    print(f"⚠️  {version}: 체크섬 불일치 - 파일이 변경되었습니다")
                    continue
            
            print(f"📦 {version}: 마이그레이션 적용 중...")
            if apply_migration(connection, migration_file):
                print(f"✅ {version}: 마이그레이션 적용 완료")
                success_count += 1
            else:
                print(f"❌ {version}: 마이그레이션 적용 실패")
                break
        
        print(f"\n📊 마이그레이션 결과: {success_count}/{len(migration_files)} 성공")
        return success_count == len(migration_files)
        
    finally:
        connection.close()

def main():
    """메인 함수"""
    if len(sys.argv) > 1 and sys.argv[1] == "--help":
        print("사용법: python migrate.py")
        print("CoE 프로젝트 데이터베이스 마이그레이션을 실행합니다.")
        return
    
    success = run_migrations()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
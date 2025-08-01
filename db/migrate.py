#!/usr/bin/env python3
"""
CoE 프로젝트 데이터베이스 마이그레이션 스크립트
"""

import os
import sys
import mysql.connector
from datetime import datetime
from dotenv import load_dotenv

# 환경 변수 로드
load_dotenv()

# 데이터베이스 연결 설정
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", "6667"))
DB_USER = os.getenv("DB_USER", "coe_user")
DB_PASSWORD = os.getenv("DB_PASSWORD", "coe_password")
DB_NAME = os.getenv("DB_NAME", "coe_db")

class DatabaseMigrator:
    """데이터베이스 마이그레이션 관리 클래스"""
    
    def __init__(self):
        self.connection = None
        self.cursor = None
    
    def connect(self):
        """데이터베이스에 연결합니다."""
        try:
            # 먼저 데이터베이스 없이 연결
            self.connection = mysql.connector.connect(
                host=DB_HOST,
                port=DB_PORT,
                user=DB_USER,
                password=DB_PASSWORD,
                charset='utf8mb4',
                collation='utf8mb4_unicode_ci'
            )
            self.cursor = self.connection.cursor()
            
            # 데이터베이스 생성
            self.cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_NAME}")
            self.cursor.execute(f"USE {DB_NAME}")
            
            print(f"✅ 데이터베이스 '{DB_NAME}' 연결 성공")
            return True
            
        except mysql.connector.Error as e:
            print(f"❌ 데이터베이스 연결 실패: {e}")
            return False
    
    def disconnect(self):
        """데이터베이스 연결을 종료합니다."""
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()
        print("✅ 데이터베이스 연결 종료")
    
    def create_migration_table(self):
        """마이그레이션 추적 테이블을 생성합니다."""
        try:
            create_table_sql = """
            CREATE TABLE IF NOT EXISTS schema_migrations (
                id INT AUTO_INCREMENT PRIMARY KEY,
                version VARCHAR(255) UNIQUE NOT NULL,
                description TEXT,
                executed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_version (version)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            """
            
            self.cursor.execute(create_table_sql)
            self.connection.commit()
            print("✅ 마이그레이션 테이블 생성 완료")
            return True
            
        except mysql.connector.Error as e:
            print(f"❌ 마이그레이션 테이블 생성 실패: {e}")
            return False
    
    def is_migration_executed(self, version):
        """특정 마이그레이션이 실행되었는지 확인합니다."""
        try:
            self.cursor.execute(
                "SELECT COUNT(*) FROM schema_migrations WHERE version = %s",
                (version,)
            )
            count = self.cursor.fetchone()[0]
            return count > 0
            
        except mysql.connector.Error as e:
            print(f"❌ 마이그레이션 상태 확인 실패: {e}")
            return False
    
    def record_migration(self, version, description):
        """마이그레이션 실행 기록을 저장합니다."""
        try:
            self.cursor.execute(
                "INSERT INTO schema_migrations (version, description) VALUES (%s, %s)",
                (version, description)
            )
            self.connection.commit()
            print(f"✅ 마이그레이션 {version} 기록 완료")
            return True
            
        except mysql.connector.Error as e:
            print(f"❌ 마이그레이션 기록 실패: {e}")
            return False
    
    def execute_sql_file(self, filepath):
        """SQL 파일을 실행합니다."""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                sql_content = f.read()
            
            # SQL 문을 세미콜론으로 분리하여 실행
            statements = [stmt.strip() for stmt in sql_content.split(';') if stmt.strip()]
            
            for statement in statements:
                if statement:
                    self.cursor.execute(statement)
            
            self.connection.commit()
            print(f"✅ SQL 파일 실행 완료: {filepath}")
            return True
            
        except Exception as e:
            print(f"❌ SQL 파일 실행 실패: {filepath} - {e}")
            self.connection.rollback()
            return False
    
    def run_migrations(self):
        """모든 마이그레이션을 실행합니다."""
        migrations = [
            {
                'version': '001_create_database',
                'description': '데이터베이스 및 사용자 생성',
                'file': 'init/01_create_database.sql'
            },
            {
                'version': '002_create_tables',
                'description': '기본 테이블 생성',
                'file': 'init/02_create_tables.sql'
            }
        ]
        
        success_count = 0
        
        for migration in migrations:
            version = migration['version']
            description = migration['description']
            filepath = os.path.join(os.path.dirname(__file__), migration['file'])
            
            print(f"\n🔄 마이그레이션 실행 중: {version} - {description}")
            
            if self.is_migration_executed(version):
                print(f"⏭️  마이그레이션 {version} 이미 실행됨")
                success_count += 1
                continue
            
            if not os.path.exists(filepath):
                print(f"❌ 마이그레이션 파일 없음: {filepath}")
                continue
            
            if self.execute_sql_file(filepath):
                if self.record_migration(version, description):
                    success_count += 1
                    print(f"✅ 마이그레이션 {version} 완료")
                else:
                    print(f"❌ 마이그레이션 {version} 기록 실패")
            else:
                print(f"❌ 마이그레이션 {version} 실행 실패")
        
        print(f"\n📊 마이그레이션 결과: {success_count}/{len(migrations)} 성공")
        return success_count == len(migrations)
    
    def check_database_status(self):
        """데이터베이스 상태를 확인합니다."""
        try:
            # 테이블 목록 조회
            self.cursor.execute("SHOW TABLES")
            tables = [table[0] for table in self.cursor.fetchall()]
            
            print(f"\n📋 데이터베이스 상태:")
            print(f"   데이터베이스: {DB_NAME}")
            print(f"   테이블 수: {len(tables)}")
            
            if tables:
                print("   테이블 목록:")
                for table in sorted(tables):
                    self.cursor.execute(f"SELECT COUNT(*) FROM {table}")
                    count = self.cursor.fetchone()[0]
                    print(f"     - {table}: {count} rows")
            
            # 마이그레이션 기록 조회
            if 'schema_migrations' in tables:
                self.cursor.execute("SELECT version, description, executed_at FROM schema_migrations ORDER BY executed_at")
                migrations = self.cursor.fetchall()
                
                if migrations:
                    print("\n   실행된 마이그레이션:")
                    for version, description, executed_at in migrations:
                        print(f"     - {version}: {description} ({executed_at})")
            
            return True
            
        except mysql.connector.Error as e:
            print(f"❌ 데이터베이스 상태 확인 실패: {e}")
            return False

def main():
    """메인 함수"""
    print("🚀 CoE 데이터베이스 마이그레이션 시작")
    
    migrator = DatabaseMigrator()
    
    try:
        # 데이터베이스 연결
        if not migrator.connect():
            return False
        
        # 마이그레이션 테이블 생성
        if not migrator.create_migration_table():
            return False
        
        # 마이그레이션 실행
        if not migrator.run_migrations():
            print("❌ 일부 마이그레이션이 실패했습니다.")
            return False
        
        # 데이터베이스 상태 확인
        migrator.check_database_status()
        
        print("\n🎉 모든 마이그레이션이 성공적으로 완료되었습니다!")
        return True
        
    except Exception as e:
        print(f"❌ 마이그레이션 중 오류 발생: {e}")
        return False
        
    finally:
        migrator.disconnect()

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
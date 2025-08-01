#!/usr/bin/env python3
"""
데이터베이스 영속성 통합 테스트 스크립트
"""

import sys
import os

# 프로젝트 경로 추가
sys.path.append(os.path.join(os.path.dirname(__file__), 'CoE-Backend'))
sys.path.append(os.path.join(os.path.dirname(__file__), 'CoE-RagPipeline'))

# 테스트용 환경 변수 설정
os.environ['DB_HOST'] = 'localhost'
os.environ['DB_PORT'] = '6667'
os.environ['DB_USER'] = 'coe_user'
os.environ['DB_PASSWORD'] = 'coe_password'
os.environ['DB_NAME'] = 'coe_db'

def test_backend_database():
    """CoE-Backend 데이터베이스 테스트"""
    print("🔍 Testing CoE-Backend Database Integration...")
    
    try:
        from core.database import init_database, test_connection
        from services.db_service import LangFlowService
        from core.database import SessionLocal
        
        # 1. 데이터베이스 연결 테스트
        print("1. Testing database connection...")
        if not test_connection():
            print("❌ Database connection failed")
            return False
        print("✅ Database connection successful")
        
        # 2. 데이터베이스 초기화
        print("2. Initializing database...")
        if not init_database():
            print("❌ Database initialization failed")
            return False
        print("✅ Database initialization successful")
        
        # 3. LangFlow CRUD 테스트
        print("3. Testing LangFlow CRUD operations...")
        db = SessionLocal()
        try:
            # Create
            flow_data = {
                "nodes": [{"id": "1", "type": "test", "data": {"label": "Test Node"}}],
                "edges": []
            }
            
            import time
            unique_name = f"test_flow_integration_{int(time.time())}"
            
            langflow = LangFlowService.create_flow(
                db=db,
                name=unique_name,
                description="Test flow for integration testing",
                flow_data=flow_data
            )
            print(f"✅ Created LangFlow: {langflow.name}")
            
            # Read
            retrieved_flow = LangFlowService.get_flow_by_name(db, unique_name)
            if retrieved_flow:
                print(f"✅ Retrieved LangFlow: {retrieved_flow.name}")
            else:
                print("❌ Failed to retrieve LangFlow")
                return False
            
            # Delete
            if LangFlowService.delete_flow(db, unique_name):
                print("✅ Deleted LangFlow successfully")
            else:
                print("❌ Failed to delete LangFlow")
                return False
                
        finally:
            db.close()
        
        return True
        
    except Exception as e:
        print(f"❌ Backend database test failed: {e}")
        return False

def test_ragpipeline_database():
    """CoE-RagPipeline 데이터베이스 테스트"""
    print("\n🔍 Testing CoE-RagPipeline Database Integration...")
    
    try:
        from core.database import init_database, test_connection
        from core.database import SessionLocal, RagAnalysisResult, AnalysisStatus
        
        # 1. 데이터베이스 연결 테스트
        print("1. Testing database connection...")
        if not test_connection():
            print("❌ Database connection failed")
            return False
        print("✅ Database connection successful")
        
        # 2. 데이터베이스 초기화
        print("2. Initializing database...")
        if not init_database():
            print("❌ Database initialization failed")
            return False
        print("✅ Database initialization successful")
        
        # 3. RagAnalysisResult CRUD 테스트
        print("3. Testing RagAnalysisResult CRUD operations...")
        db = SessionLocal()
        try:
            import uuid
            from datetime import datetime
            
            # Create
            analysis_id = str(uuid.uuid4())
            
            rag_result = RagAnalysisResult(
                analysis_id=analysis_id,
                git_url="https://github.com/test/repo.git",
                analysis_date=datetime.now(),
                status=AnalysisStatus.PENDING,
                repository_count=1,
                total_files=10,
                total_lines_of_code=1000,
                repositories_data='[]',
                correlation_data='null',
                tech_specs_summary='[]'
            )
            
            db.add(rag_result)
            db.commit()
            db.refresh(rag_result)
            print(f"✅ Created RagAnalysisResult: {rag_result.analysis_id}")
            
            # Read
            retrieved_result = db.query(RagAnalysisResult).filter(
                RagAnalysisResult.analysis_id == analysis_id
            ).first()
            
            if retrieved_result:
                print(f"✅ Retrieved RagAnalysisResult: {retrieved_result.analysis_id}")
            else:
                print("❌ Failed to retrieve RagAnalysisResult")
                return False
            
            # Update
            retrieved_result.status = AnalysisStatus.COMPLETED
            db.commit()
            print("✅ Updated RagAnalysisResult status")
            
            # Delete
            db.delete(retrieved_result)
            db.commit()
            print("✅ Deleted RagAnalysisResult successfully")
                
        finally:
            db.close()
        
        return True
        
    except Exception as e:
        print(f"❌ RagPipeline database test failed: {e}")
        return False

def main():
    """메인 테스트 함수"""
    print("🚀 Starting Database Integration Tests...")
    
    backend_success = test_backend_database()
    ragpipeline_success = test_ragpipeline_database()
    
    print("\n📊 Test Results:")
    print(f"CoE-Backend Database: {'✅ PASS' if backend_success else '❌ FAIL'}")
    print(f"CoE-RagPipeline Database: {'✅ PASS' if ragpipeline_success else '❌ FAIL'}")
    
    if backend_success and ragpipeline_success:
        print("\n🎉 All database integration tests passed!")
        return True
    else:
        print("\n💥 Some database integration tests failed!")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
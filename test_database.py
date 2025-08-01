#!/usr/bin/env python3
"""
CoE 프로젝트 데이터베이스 연결 및 CRUD 기능 테스트 스크립트
"""

import sys
import os
import json
from datetime import datetime
from typing import Dict, Any

# 프로젝트 경로 추가
sys.path.append(os.path.join(os.path.dirname(__file__), 'CoE-Backend'))
sys.path.append(os.path.join(os.path.dirname(__file__), 'CoE-RagPipeline'))

# 테스트용 환경 변수 설정 (Docker 외부에서 실행할 때)
os.environ['DB_HOST'] = 'localhost'
os.environ['DB_PORT'] = '6667'
os.environ['DB_USER'] = 'coe_user'
os.environ['DB_PASSWORD'] = 'coe_password'
os.environ['DB_NAME'] = 'coe_db'

def test_backend_database():
    """CoE-Backend 데이터베이스 연결 및 기본 CRUD 테스트"""
    print("🔍 Testing CoE-Backend Database...")
    
    try:
        import sys
        sys.path.append('./CoE-Backend')
        from core.database import init_database, test_connection, SessionLocal
        from services.db_service import LangFlowService
        from services.analysis_service import AnalysisService, DevelopmentStandardService
        from core.database import StandardType
        
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
            
            # 고유한 이름 생성
            import time
            unique_name = f"test_flow_crud_{int(time.time())}"
            
            langflow = LangFlowService.create_flow(
                db=db,
                name=unique_name,
                description="Test flow for CRUD operations",
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
            
            # Update
            updated_flow = LangFlowService.update_flow(
                db=db,
                name=unique_name,
                description="Updated test flow description"
            )
            if updated_flow:
                print(f"✅ Updated LangFlow: {updated_flow.description}")
            else:
                print("❌ Failed to update LangFlow")
                return False
            
            # List all flows
            all_flows = LangFlowService.get_all_flows(db)
            print(f"✅ Retrieved {len(all_flows)} flows")
            
            # Delete
            if LangFlowService.delete_flow(db, unique_name):
                print("✅ Deleted LangFlow successfully")
            else:
                print("❌ Failed to delete LangFlow")
                return False
                
        finally:
            db.close()
        
        # 4. Analysis Service 테스트
        print("4. Testing Analysis Service...")
        db = SessionLocal()
        try:
            # Create analysis request
            repositories = [
                {"url": "https://github.com/test/repo1", "branch": "main"},
                {"url": "https://github.com/test/repo2", "branch": "develop"}
            ]
            
            analysis = AnalysisService.create_analysis_request(
                db=db,
                repositories=repositories,
                include_ast=True,
                include_tech_spec=True,
                include_correlation=False
            )
            print(f"✅ Created Analysis Request: {analysis.analysis_id}")
            
            # Update analysis status
            from core.database import AnalysisStatus
            updated_analysis = AnalysisService.update_analysis_status(
                db=db,
                analysis_id=analysis.analysis_id,
                status=AnalysisStatus.COMPLETED
            )
            if updated_analysis:
                print(f"✅ Updated Analysis Status: {updated_analysis.status}")
            
            # Create development standard
            dev_standard = DevelopmentStandardService.create_development_standard(
                db=db,
                analysis_id=analysis.analysis_id,
                standard_type=StandardType.CODING_STYLE,
                title="Test Coding Style Guide",
                content="This is a test coding style guide.",
                examples={"naming": ["snake_case", "camelCase"]},
                recommendations={"tools": ["black", "flake8"]}
            )
            print(f"✅ Created Development Standard: {dev_standard.title}")
            
        finally:
            db.close()
            
        print("✅ CoE-Backend database tests completed successfully!")
        return True
        
    except Exception as e:
        print(f"❌ CoE-Backend database test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_ragpipeline_database():
    """CoE-RagPipeline 데이터베이스 연결 및 기본 CRUD 테스트"""
    print("\n🔍 Testing CoE-RagPipeline Database...")
    
    try:
        # 직접 모듈 경로 지정
        import importlib.util
        import sys
        
        # core.database 모듈 로드
        db_spec = importlib.util.spec_from_file_location(
            "rag_database", 
            "./CoE-RagPipeline/core/database.py"
        )
        rag_database = importlib.util.module_from_spec(db_spec)
        db_spec.loader.exec_module(rag_database)
        
        # services.analysis_service 모듈 로드
        service_spec = importlib.util.spec_from_file_location(
            "rag_analysis_service", 
            "./CoE-RagPipeline/services/analysis_service.py"
        )
        rag_analysis_service = importlib.util.module_from_spec(service_spec)
        service_spec.loader.exec_module(rag_analysis_service)
        
        # 필요한 클래스들 가져오기
        init_database = rag_database.init_database
        test_connection = rag_database.test_connection
        SessionLocal = rag_database.SessionLocal
        RagAnalysisService = rag_analysis_service.RagAnalysisService
        RagRepositoryAnalysisService = rag_analysis_service.RagRepositoryAnalysisService
        RagCodeFileService = rag_analysis_service.RagCodeFileService
        RagTechDependencyService = rag_analysis_service.RagTechDependencyService
        
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
        
        # 3. RAG Analysis Service 테스트
        print("3. Testing RAG Analysis Service...")
        db = SessionLocal()
        try:
            # Create analysis request
            repositories = [
                {"url": "https://github.com/test/rag-repo1", "branch": "main"}
            ]
            
            analysis = RagAnalysisService.create_analysis_request(
                db=db,
                repositories=repositories,
                include_ast=True,
                include_tech_spec=True,
                include_correlation=False
            )
            print(f"✅ Created RAG Analysis Request: {analysis.analysis_id}")
            
            # Start analysis
            started_analysis = RagAnalysisService.start_analysis(db, analysis.analysis_id)
            if started_analysis:
                print(f"✅ Started Analysis: {started_analysis.status}")
            
            # Create repository analysis
            repo_analysis = RagRepositoryAnalysisService.create_repository_analysis(
                db=db,
                analysis_id=analysis.analysis_id,
                repository_url="https://github.com/test/rag-repo1",
                repository_name="rag-repo1",
                branch="main",
                clone_path="/tmp/rag-repo1"
            )
            print(f"✅ Created Repository Analysis: {repo_analysis.repository_name}")
            
            # Save analysis results
            saved_repo = RagRepositoryAnalysisService.save_analysis_results(
                db=db,
                repo_analysis_id=repo_analysis.id,
                files_count=10,
                lines_of_code=1000,
                languages=["Python", "JavaScript"],
                frameworks=["FastAPI", "React"],
                dependencies=["fastapi", "react", "axios"]
            )
            if saved_repo:
                print(f"✅ Saved Repository Analysis Results: {saved_repo.files_count} files")
            
            # Create code files batch
            files_data = [
                {
                    "path": "/src/main.py",
                    "name": "main.py",
                    "size": 1024,
                    "language": "Python",
                    "lines_of_code": 50
                },
                {
                    "path": "/src/utils.py",
                    "name": "utils.py",
                    "size": 512,
                    "language": "Python",
                    "lines_of_code": 25
                }
            ]
            
            code_files = RagCodeFileService.create_code_files_batch(
                db=db,
                repository_analysis_id=repo_analysis.id,
                files_data=files_data
            )
            print(f"✅ Created {len(code_files)} code files")
            
            # Create tech dependencies batch
            dependencies_data = [
                {
                    "type": "FRAMEWORK",
                    "name": "FastAPI",
                    "version": "0.104.1",
                    "package_manager": "pip",
                    "is_dev_dependency": False
                },
                {
                    "type": "LIBRARY",
                    "name": "requests",
                    "version": "2.31.0",
                    "package_manager": "pip",
                    "is_dev_dependency": False
                }
            ]
            
            tech_deps = RagTechDependencyService.create_tech_dependencies_batch(
                db=db,
                repository_analysis_id=repo_analysis.id,
                dependencies_data=dependencies_data
            )
            print(f"✅ Created {len(tech_deps)} tech dependencies")
            
            # Complete analysis
            completed_analysis = RagAnalysisService.complete_analysis(db, analysis.analysis_id)
            if completed_analysis:
                print(f"✅ Completed Analysis: {completed_analysis.status}")
            
        finally:
            db.close()
            
        print("✅ CoE-RagPipeline database tests completed successfully!")
        return True
        
    except Exception as e:
        print(f"❌ CoE-RagPipeline database test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """메인 테스트 함수"""
    print("🚀 Starting CoE Database Tests...")
    print("=" * 60)
    
    # Backend 테스트
    backend_success = test_backend_database()
    
    # RagPipeline 테스트
    ragpipeline_success = test_ragpipeline_database()
    
    # 결과 요약
    print("\n" + "=" * 60)
    print("📊 Test Results Summary:")
    print(f"CoE-Backend Database: {'✅ PASSED' if backend_success else '❌ FAILED'}")
    print(f"CoE-RagPipeline Database: {'✅ PASSED' if ragpipeline_success else '❌ FAILED'}")
    
    if backend_success and ragpipeline_success:
        print("\n🎉 All database tests passed successfully!")
        return 0
    else:
        print("\n💥 Some database tests failed!")
        return 1

if __name__ == "__main__":
    exit(main())
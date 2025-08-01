#!/usr/bin/env python3
import requests
import json
import time

def test_complete_integration():
    """완전한 임베딩-벡터 통합 테스트"""
    print("=== 완전한 임베딩-벡터 통합 테스트 ===")
    
    # 테스트 문서들
    test_documents = [
        {
            "page_content": "Python은 간단하고 읽기 쉬운 프로그래밍 언어입니다. 데이터 과학과 웹 개발에 널리 사용됩니다.",
            "metadata": {"source": "python_guide", "type": "programming", "language": "ko"}
        },
        {
            "page_content": "FastAPI는 Python으로 API를 빠르게 구축할 수 있는 현대적인 웹 프레임워크입니다.",
            "metadata": {"source": "fastapi_guide", "type": "framework", "language": "ko"}
        },
        {
            "page_content": "Docker는 애플리케이션을 컨테이너로 패키징하여 배포를 간소화하는 플랫폼입니다.",
            "metadata": {"source": "docker_guide", "type": "devops", "language": "ko"}
        }
    ]
    
    # 1. 임베딩 API 테스트
    print("\n1. 임베딩 API 개별 테스트")
    for i, doc in enumerate(test_documents):
        try:
            response = requests.post(
                "http://localhost:8000/v1/embeddings",
                headers={"Content-Type": "application/json"},
                json={
                    "input": doc["page_content"],
                    "model": "ko-sentence-bert"
                },
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                print(f"  ✅ 문서 {i+1} 임베딩 성공 - 차원: {len(result['data'][0]['embedding'])}")
            else:
                print(f"  ❌ 문서 {i+1} 임베딩 실패: {response.text}")
                
        except Exception as e:
            print(f"  ❌ 문서 {i+1} 임베딩 예외: {e}")
    
    # 2. 벡터 데이터베이스에 문서 추가
    print("\n2. 벡터 데이터베이스에 문서 추가")
    try:
        response = requests.post(
            "http://localhost:8000/vector/add",
            headers={"Content-Type": "application/json"},
            json={"documents": test_documents},
            timeout=60
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"  ✅ 문서 추가 성공: {result['success_count']}개")
            print(f"  📄 문서 ID들: {result['document_ids']}")
        else:
            print(f"  ❌ 문서 추가 실패: {response.text}")
            return
            
    except Exception as e:
        print(f"  ❌ 문서 추가 예외: {e}")
        return
    
    # 잠시 대기 (인덱싱 완료를 위해)
    print("\n⏳ 인덱싱 완료 대기 중...")
    time.sleep(2)
    
    # 3. 벡터 검색 테스트
    print("\n3. 벡터 검색 테스트")
    search_queries = [
        "Python 프로그래밍 언어",
        "웹 프레임워크",
        "컨테이너 배포",
        "데이터 과학"
    ]
    
    for query in search_queries:
        try:
            response = requests.post(
                "http://localhost:8000/vector/search",
                headers={"Content-Type": "application/json"},
                json={
                    "query": query,
                    "k": 3
                },
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                print(f"\n  🔍 쿼리: '{query}'")
                print(f"  📊 결과 수: {result['total_count']}")
                
                for i, doc in enumerate(result['documents']):
                    content = doc['page_content'][:80] + "..." if len(doc['page_content']) > 80 else doc['page_content']
                    print(f"    {i+1}. {content}")
                    print(f"       메타데이터: {doc['metadata']}")
            else:
                print(f"  ❌ 검색 실패 '{query}': {response.text}")
                
        except Exception as e:
            print(f"  ❌ 검색 예외 '{query}': {e}")
    
    # 4. 점수와 함께 검색 테스트
    print("\n4. 점수와 함께 검색 테스트")
    try:
        response = requests.post(
            "http://localhost:8000/vector/search_with_score",
            headers={"Content-Type": "application/json"},
            json={
                "query": "Python 웹 개발",
                "k": 3
            },
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"  🔍 쿼리: 'Python 웹 개발'")
            print(f"  📊 결과 수: {result['total_count']}")
            
            for i, item in enumerate(result['results']):
                doc = item['document']
                score = item['score']
                content = doc['page_content'][:60] + "..." if len(doc['page_content']) > 60 else doc['page_content']
                print(f"    {i+1}. (점수: {score:.4f}) {content}")
        else:
            print(f"  ❌ 점수 검색 실패: {response.text}")
            
    except Exception as e:
        print(f"  ❌ 점수 검색 예외: {e}")
    
    # 5. 컬렉션 정보 확인
    print("\n5. 컬렉션 정보 확인")
    try:
        response = requests.get("http://localhost:8000/vector/info", timeout=10)
        
        if response.status_code == 200:
            result = response.json()
            print(f"  ✅ 컬렉션 정보:")
            print(f"    - 이름: {result['collection_name']}")
            print(f"    - 문서 수: {result['document_count']}")
            print(f"    - 호스트: {result['host']}:{result['port']}")
        else:
            print(f"  ❌ 컬렉션 정보 조회 실패: {response.text}")
            
    except Exception as e:
        print(f"  ❌ 컬렉션 정보 조회 예외: {e}")
    
    print("\n🎉 통합 테스트 완료!")

if __name__ == "__main__":
    test_complete_integration()
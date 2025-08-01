#!/usr/bin/env python3
"""
CoE 플랫폼 API 테스트 스크립트
"""

import requests
import json
import time

def test_coe_backend():
    """CoE-Backend API 테스트"""
    print("=== CoE-Backend API 테스트 ===")
    
    # 1. 헬스체크
    try:
        response = requests.get("http://localhost:8000/health")
        print(f"헬스체크: {response.status_code} - {response.json()}")
    except Exception as e:
        print(f"헬스체크 실패: {e}")
    
    # 2. 모델 목록 조회
    try:
        response = requests.get("http://localhost:8000/v1/models")
        print(f"모델 목록: {response.status_code}")
        if response.status_code == 200:
            models = response.json()
            print(f"사용 가능한 모델: {[model['id'] for model in models['data']]}")
    except Exception as e:
        print(f"모델 목록 조회 실패: {e}")
    
    # 3. AI 에이전트 테스트
    try:
        payload = {
            "model": "coe-agent-v1",
            "messages": [
                {
                    "role": "user",
                    "content": "안녕하세요! CoE 에이전트가 정상적으로 동작하는지 간단한 응답을 해주세요."
                }
            ],
            "stream": False
        }
        
        response = requests.post(
            "http://localhost:8000/v1/chat/completions",
            headers={"Content-Type": "application/json"},
            json=payload,
            timeout=30
        )
        
        print(f"AI 에이전트 응답: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"응답 내용: {result['choices'][0]['message']['content'][:200]}...")
        else:
            print(f"에러 응답: {response.text}")
            
    except Exception as e:
        print(f"AI 에이전트 테스트 실패: {e}")

def test_coe_rag_pipeline():
    """CoE-RagPipeline API 테스트"""
    print("\n=== CoE-RagPipeline API 테스트 ===")
    
    # 1. 헬스체크
    try:
        response = requests.get("http://localhost:8001/health")
        print(f"헬스체크: {response.status_code} - {response.json()}")
    except Exception as e:
        print(f"헬스체크 실패: {e}")
    
    # 2. 기존 분석 결과 조회
    try:
        response = requests.get("http://localhost:8001/api/v1/results")
        print(f"분석 결과 목록: {response.status_code}")
        if response.status_code == 200:
            results = response.json()
            print(f"총 {len(results)}개의 분석 결과 존재")
            if results:
                # 가장 최근 완료된 분석 결과 조회
                completed_results = [r for r in results if r['status'] == 'completed']
                if completed_results:
                    latest = completed_results[0]
                    print(f"최신 완료 분석: {latest['analysis_id']} ({latest['created_at']})")
                    
                    # 상세 결과 조회
                    detail_response = requests.get(f"http://localhost:8001/api/v1/results/{latest['analysis_id']}")
                    if detail_response.status_code == 200:
                        detail = detail_response.json()
                        print(f"분석 대상 레포지토리: {len(detail.get('repositories', []))}개")
                        print(f"총 파일 수: {len(detail.get('files', []))}")
                        print("분석 완료!")
                    else:
                        print(f"상세 결과 조회 실패: {detail_response.status_code}")
    except Exception as e:
        print(f"분석 결과 조회 실패: {e}")

def test_embedding_service():
    """임베딩 서비스 테스트"""
    print("\n=== 임베딩 서비스 테스트 ===")
    
    try:
        # 임베딩 서비스 직접 테스트
        response = requests.get("http://localhost:6668/health", timeout=5)
        print(f"임베딩 서비스 헬스체크: {response.status_code}")
    except Exception as e:
        print(f"임베딩 서비스 연결 실패: {e}")
    
    # CoE-Backend를 통한 임베딩 테스트
    try:
        payload = {
            "model": "ko-sentence-bert",
            "input": ["안녕하세요", "테스트 문장입니다"]
        }
        
        response = requests.post(
            "http://localhost:8000/v1/embeddings",
            headers={"Content-Type": "application/json"},
            json=payload,
            timeout=10
        )
        
        print(f"임베딩 API 응답: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"임베딩 벡터 수: {len(result['data'])}")
            print(f"벡터 차원: {len(result['data'][0]['embedding'])}")
        else:
            print(f"임베딩 에러: {response.text}")
            
    except Exception as e:
        print(f"임베딩 테스트 실패: {e}")

def test_vector_search():
    """벡터 검색 테스트"""
    print("\n=== 벡터 검색 테스트 ===")
    
    try:
        payload = {
            "query": "Python 코드 분석",
            "top_k": 5
        }
        
        response = requests.post(
            "http://localhost:8000/vector/search",
            headers={"Content-Type": "application/json"},
            json=payload,
            timeout=10
        )
        
        print(f"벡터 검색 응답: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"검색 결과 수: {len(result.get('results', []))}")
        else:
            print(f"벡터 검색 에러: {response.text}")
            
    except Exception as e:
        print(f"벡터 검색 테스트 실패: {e}")

if __name__ == "__main__":
    print("CoE 플랫폼 기능 점검을 시작합니다...\n")
    
    test_coe_backend()
    test_coe_rag_pipeline()
    test_embedding_service()
    test_vector_search()
    
    print("\n=== 기능 점검 완료 ===")
#!/usr/bin/env python3
"""
벡터 API 테스트 스크립트
"""

import requests
import json

def test_vector_add():
    """벡터 문서 추가 테스트"""
    print("=== 벡터 문서 추가 테스트 ===")
    
    payload = {
        "documents": [
            {
                "page_content": "Python은 간단하고 읽기 쉬운 프로그래밍 언어입니다.",
                "metadata": {"source": "test", "type": "description"}
            },
            {
                "page_content": "FastAPI는 Python으로 API를 빠르게 개발할 수 있는 프레임워크입니다.",
                "metadata": {"source": "test", "type": "framework"}
            }
        ]
    }
    
    try:
        response = requests.post(
            "http://localhost:8000/vector/add",
            headers={"Content-Type": "application/json"},
            json=payload,
            timeout=10
        )
        
        print(f"응답 코드: {response.status_code}")
        print(f"응답 내용: {response.text}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"추가된 문서 수: {result.get('success_count', 0)}")
            return True
        else:
            print(f"에러 발생: {response.text}")
            return False
            
    except Exception as e:
        print(f"요청 실패: {e}")
        return False

def test_vector_search():
    """벡터 검색 테스트"""
    print("\n=== 벡터 검색 테스트 ===")
    
    payload = {
        "query": "Python 프로그래밍",
        "k": 5
    }
    
    try:
        response = requests.post(
            "http://localhost:8000/vector/search",
            headers={"Content-Type": "application/json"},
            json=payload,
            timeout=10
        )
        
        print(f"응답 코드: {response.status_code}")
        print(f"응답 내용: {response.text}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"검색 결과 수: {result.get('total_count', 0)}")
            return True
        else:
            print(f"에러 발생: {response.text}")
            return False
            
    except Exception as e:
        print(f"요청 실패: {e}")
        return False

def test_vector_info():
    """벡터 정보 조회 테스트"""
    print("\n=== 벡터 정보 조회 테스트 ===")
    
    try:
        response = requests.get(
            "http://localhost:8000/vector/info",
            timeout=10
        )
        
        print(f"응답 코드: {response.status_code}")
        print(f"응답 내용: {response.text}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"벡터 DB 정보: {result}")
            return True
        else:
            print(f"에러 발생: {response.text}")
            return False
            
    except Exception as e:
        print(f"요청 실패: {e}")
        return False

if __name__ == "__main__":
    print("벡터 API 테스트를 시작합니다...\n")
    
    # 1. 벡터 정보 조회
    test_vector_info()
    
    # 2. 벡터 문서 추가
    add_success = test_vector_add()
    
    # 3. 벡터 검색 (추가가 성공한 경우에만)
    if add_success:
        test_vector_search()
    
    print("\n=== 벡터 API 테스트 완료 ===")
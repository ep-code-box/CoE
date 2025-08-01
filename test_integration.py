#!/usr/bin/env python3
"""
CoE 플랫폼 통합 워크플로우 테스트
"""

import requests
import json
import time

def test_full_workflow():
    """전체 워크플로우 테스트: 분석 → 가이드 생성"""
    print("=== CoE 플랫폼 통합 워크플로우 테스트 ===")
    
    # 1. 기존 분석 결과 확인
    print("1. 기존 분석 결과 확인...")
    try:
        response = requests.get("http://localhost:8001/api/v1/results")
        if response.status_code == 200:
            results = response.json()
            completed_results = [r for r in results if r['status'] == 'completed']
            
            if completed_results:
                analysis_id = completed_results[0]['analysis_id']
                print(f"✅ 기존 완료된 분석 발견: {analysis_id}")
                
                # 2. AI 에이전트에게 가이드 생성 요청
                print("2. AI 에이전트에게 개발 가이드 생성 요청...")
                
                payload = {
                    "model": "coe-agent-v1",
                    "messages": [
                        {
                            "role": "user",
                            "content": f"analysis_id {analysis_id}로 개발 가이드를 추출해주세요. 코딩 스타일, 아키텍처 패턴, 공통 함수에 대한 가이드를 생성해주세요."
                        }
                    ],
                    "stream": False
                }
                
                response = requests.post(
                    "http://localhost:8000/v1/chat/completions",
                    headers={"Content-Type": "application/json"},
                    json=payload,
                    timeout=60
                )
                
                if response.status_code == 200:
                    result = response.json()
                    guide_content = result['choices'][0]['message']['content']
                    print("✅ 개발 가이드 생성 완료!")
                    print(f"가이드 내용 (처음 500자): {guide_content[:500]}...")
                    return True
                else:
                    print(f"❌ 가이드 생성 실패: {response.text}")
                    return False
            else:
                print("❌ 완료된 분석 결과가 없습니다.")
                return False
        else:
            print(f"❌ 분석 결과 조회 실패: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ 통합 테스트 실패: {e}")
        return False

def test_new_analysis_workflow():
    """새로운 분석 워크플로우 테스트"""
    print("\n=== 새로운 분석 워크플로우 테스트 ===")
    
    # 1. 새로운 분석 시작 (간단한 레포지토리)
    print("1. 새로운 Git 분석 시작...")
    
    payload = {
        "repositories": [
            {
                "url": "https://github.com/octocat/Hello-World.git",
                "branch": "master"
            }
        ],
        "include_ast": True,
        "include_tech_spec": True,
        "include_correlation": False
    }
    
    try:
        response = requests.post(
            "http://localhost:8001/api/v1/analyze",
            headers={"Content-Type": "application/json"},
            json=payload,
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            analysis_id = result.get('analysis_id')
            print(f"✅ 분석 시작됨: {analysis_id}")
            
            # 2. 분석 완료 대기 (최대 60초)
            print("2. 분석 완료 대기...")
            for i in range(12):  # 5초씩 12번 = 60초
                time.sleep(5)
                
                status_response = requests.get(f"http://localhost:8001/api/v1/results/{analysis_id}")
                if status_response.status_code == 200:
                    status_data = status_response.json()
                    status = status_data.get('status')
                    
                    if status == 'completed':
                        print("✅ 분석 완료!")
                        return analysis_id
                    elif status == 'failed':
                        print("❌ 분석 실패")
                        return None
                    else:
                        print(f"⏳ 분석 진행 중... ({status})")
                else:
                    print(f"⚠️ 상태 확인 실패: {status_response.status_code}")
            
            print("⏰ 분석 시간 초과")
            return None
        else:
            print(f"❌ 분석 시작 실패: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ 새로운 분석 워크플로우 실패: {e}")
        return None

def test_coding_assistant():
    """코딩 어시스턴트 기능 테스트"""
    print("\n=== 코딩 어시스턴트 기능 테스트 ===")
    
    # 1. 지원 언어 조회
    try:
        response = requests.get("http://localhost:8000/coding-assistant/languages")
        if response.status_code == 200:
            languages = response.json()
            print(f"✅ 지원 언어: {languages}")
        else:
            print(f"❌ 언어 조회 실패: {response.status_code}")
    except Exception as e:
        print(f"❌ 언어 조회 오류: {e}")
    
    # 2. 코드 분석 테스트
    try:
        payload = {
            "code": "def hello_world():\n    print('Hello, World!')\n    return 'success'",
            "language": "python"
        }
        
        response = requests.post(
            "http://localhost:8000/coding-assistant/analyze",
            headers={"Content-Type": "application/json"},
            json=payload,
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ 코드 분석 완료!")
            print(f"분석 결과: {result.get('summary', 'N/A')}")
        else:
            print(f"❌ 코드 분석 실패: {response.text}")
            
    except Exception as e:
        print(f"❌ 코드 분석 오류: {e}")

if __name__ == "__main__":
    print("CoE 플랫폼 통합 테스트를 시작합니다...\n")
    
    # 1. 기존 분석 결과로 전체 워크플로우 테스트
    workflow_success = test_full_workflow()
    
    # 2. 새로운 분석 워크플로우 테스트 (선택적)
    # new_analysis_id = test_new_analysis_workflow()
    
    # 3. 코딩 어시스턴트 기능 테스트
    test_coding_assistant()
    
    print("\n=== 통합 테스트 결과 ===")
    if workflow_success:
        print("✅ 전체 워크플로우 테스트 성공!")
    else:
        print("❌ 전체 워크플로우 테스트 실패")
    
    print("\n=== 통합 테스트 완료 ===")
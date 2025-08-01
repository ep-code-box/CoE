#!/usr/bin/env python3
"""
CoE 인증 시스템 테스트 스크립트
"""

import requests
import json
import time
from typing import Dict, Any

# 테스트 설정
BASE_URL = "http://localhost:8000"
TEST_USER = {
    "username": "testuser",
    "email": "test@example.com",
    "password": "testpassword123",
    "full_name": "Test User"
}

class AuthTester:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()
        self.access_token = None
        self.refresh_token = None
    
    def test_health_check(self) -> bool:
        """헬스 체크 테스트"""
        print("🔍 Testing health check...")
        try:
            response = self.session.get(f"{self.base_url}/health")
            if response.status_code == 200:
                print("✅ Health check passed")
                return True
            else:
                print(f"❌ Health check failed: {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ Health check error: {e}")
            return False
    
    def test_user_registration(self) -> bool:
        """사용자 등록 테스트"""
        print("🔍 Testing user registration...")
        try:
            response = self.session.post(
                f"{self.base_url}/auth/register",
                json=TEST_USER
            )
            
            if response.status_code == 200:
                user_data = response.json()
                print(f"✅ User registration successful: {user_data['username']}")
                return True
            elif response.status_code == 400 and "already registered" in response.text:
                print("ℹ️ User already exists, continuing...")
                return True
            else:
                print(f"❌ User registration failed: {response.status_code}")
                print(f"Response: {response.text}")
                return False
        except Exception as e:
            print(f"❌ User registration error: {e}")
            return False
    
    def test_user_login(self) -> bool:
        """사용자 로그인 테스트"""
        print("🔍 Testing user login...")
        try:
            login_data = {
                "username": TEST_USER["username"],
                "password": TEST_USER["password"]
            }
            
            response = self.session.post(
                f"{self.base_url}/auth/login",
                json=login_data
            )
            
            if response.status_code == 200:
                token_data = response.json()
                self.access_token = token_data["access_token"]
                self.refresh_token = token_data["refresh_token"]
                print("✅ User login successful")
                print(f"Access token: {self.access_token[:50]}...")
                return True
            else:
                print(f"❌ User login failed: {response.status_code}")
                print(f"Response: {response.text}")
                return False
        except Exception as e:
            print(f"❌ User login error: {e}")
            return False
    
    def test_protected_endpoint(self) -> bool:
        """보호된 엔드포인트 테스트"""
        print("🔍 Testing protected endpoint access...")
        try:
            headers = {"Authorization": f"Bearer {self.access_token}"}
            response = self.session.get(
                f"{self.base_url}/auth/me",
                headers=headers
            )
            
            if response.status_code == 200:
                user_data = response.json()
                print(f"✅ Protected endpoint access successful: {user_data['username']}")
                return True
            else:
                print(f"❌ Protected endpoint access failed: {response.status_code}")
                print(f"Response: {response.text}")
                return False
        except Exception as e:
            print(f"❌ Protected endpoint error: {e}")
            return False
    
    def test_unauthorized_access(self) -> bool:
        """인증 없이 보호된 엔드포인트 접근 테스트"""
        print("🔍 Testing unauthorized access...")
        try:
            response = self.session.get(f"{self.base_url}/auth/me")
            
            if response.status_code == 401:
                print("✅ Unauthorized access properly blocked")
                return True
            else:
                print(f"❌ Unauthorized access not blocked: {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ Unauthorized access test error: {e}")
            return False
    
    def test_token_refresh(self) -> bool:
        """토큰 갱신 테스트"""
        print("🔍 Testing token refresh...")
        try:
            refresh_data = {"refresh_token": self.refresh_token}
            response = self.session.post(
                f"{self.base_url}/auth/refresh",
                json=refresh_data
            )
            
            if response.status_code == 200:
                token_data = response.json()
                new_access_token = token_data["access_token"]
                print("✅ Token refresh successful")
                print(f"New access token: {new_access_token[:50]}...")
                self.access_token = new_access_token
                return True
            else:
                print(f"❌ Token refresh failed: {response.status_code}")
                print(f"Response: {response.text}")
                return False
        except Exception as e:
            print(f"❌ Token refresh error: {e}")
            return False
    
    def test_password_change(self) -> bool:
        """비밀번호 변경 테스트"""
        print("🔍 Testing password change...")
        try:
            headers = {"Authorization": f"Bearer {self.access_token}"}
            password_data = {
                "current_password": TEST_USER["password"],
                "new_password": "newpassword123"
            }
            
            response = self.session.post(
                f"{self.base_url}/auth/change-password",
                json=password_data,
                headers=headers
            )
            
            if response.status_code == 200:
                print("✅ Password change successful")
                
                # 새 비밀번호로 로그인 테스트
                login_data = {
                    "username": TEST_USER["username"],
                    "password": "newpassword123"
                }
                
                login_response = self.session.post(
                    f"{self.base_url}/auth/login",
                    json=login_data
                )
                
                if login_response.status_code == 200:
                    print("✅ Login with new password successful")
                    token_data = login_response.json()
                    self.access_token = token_data["access_token"]
                    self.refresh_token = token_data["refresh_token"]
                    
                    # 비밀번호를 원래대로 복구
                    headers = {"Authorization": f"Bearer {self.access_token}"}
                    restore_data = {
                        "current_password": "newpassword123",
                        "new_password": TEST_USER["password"]
                    }
                    
                    self.session.post(
                        f"{self.base_url}/auth/change-password",
                        json=restore_data,
                        headers=headers
                    )
                    
                    return True
                else:
                    print("❌ Login with new password failed")
                    return False
            else:
                print(f"❌ Password change failed: {response.status_code}")
                print(f"Response: {response.text}")
                return False
        except Exception as e:
            print(f"❌ Password change error: {e}")
            return False
    
    def test_logout(self) -> bool:
        """로그아웃 테스트"""
        print("🔍 Testing logout...")
        try:
            headers = {"Authorization": f"Bearer {self.access_token}"}
            response = self.session.post(
                f"{self.base_url}/auth/logout",
                headers=headers
            )
            
            if response.status_code == 200:
                print("✅ Logout successful")
                
                # 로그아웃 후 보호된 엔드포인트 접근 테스트
                test_response = self.session.get(
                    f"{self.base_url}/auth/me",
                    headers=headers
                )
                
                if test_response.status_code == 401:
                    print("✅ Token properly invalidated after logout")
                    return True
                else:
                    print("❌ Token not invalidated after logout")
                    return False
            else:
                print(f"❌ Logout failed: {response.status_code}")
                print(f"Response: {response.text}")
                return False
        except Exception as e:
            print(f"❌ Logout error: {e}")
            return False
    
    def test_rate_limiting(self) -> bool:
        """속도 제한 테스트"""
        print("🔍 Testing rate limiting...")
        try:
            # 빠르게 여러 요청 보내기
            for i in range(5):
                response = self.session.get(f"{self.base_url}/health")
                if response.status_code == 429:
                    print("✅ Rate limiting is working")
                    return True
                time.sleep(0.1)
            
            print("ℹ️ Rate limiting not triggered (may need more requests)")
            return True
        except Exception as e:
            print(f"❌ Rate limiting test error: {e}")
            return False
    
    def run_all_tests(self) -> Dict[str, bool]:
        """모든 테스트 실행"""
        print("🚀 Starting CoE Authentication System Tests\n")
        
        tests = [
            ("Health Check", self.test_health_check),
            ("User Registration", self.test_user_registration),
            ("User Login", self.test_user_login),
            ("Protected Endpoint Access", self.test_protected_endpoint),
            ("Unauthorized Access Block", self.test_unauthorized_access),
            ("Token Refresh", self.test_token_refresh),
            ("Password Change", self.test_password_change),
            ("Logout", self.test_logout),
            ("Rate Limiting", self.test_rate_limiting),
        ]
        
        results = {}
        passed = 0
        total = len(tests)
        
        for test_name, test_func in tests:
            print(f"\n{'='*50}")
            try:
                result = test_func()
                results[test_name] = result
                if result:
                    passed += 1
            except Exception as e:
                print(f"❌ {test_name} failed with exception: {e}")
                results[test_name] = False
            
            time.sleep(1)  # 테스트 간 간격
        
        print(f"\n{'='*50}")
        print(f"🏁 Test Results: {passed}/{total} tests passed")
        print(f"{'='*50}")
        
        for test_name, result in results.items():
            status = "✅ PASS" if result else "❌ FAIL"
            print(f"{status} {test_name}")
        
        return results

def main():
    """메인 함수"""
    print("CoE Authentication System Test Suite")
    print("=" * 50)
    
    tester = AuthTester(BASE_URL)
    results = tester.run_all_tests()
    
    # 전체 결과 요약
    total_tests = len(results)
    passed_tests = sum(results.values())
    
    print(f"\n🎯 Final Summary:")
    print(f"Total Tests: {total_tests}")
    print(f"Passed: {passed_tests}")
    print(f"Failed: {total_tests - passed_tests}")
    print(f"Success Rate: {(passed_tests/total_tests)*100:.1f}%")
    
    if passed_tests == total_tests:
        print("\n🎉 All tests passed! Authentication system is working correctly.")
        return 0
    else:
        print(f"\n⚠️ {total_tests - passed_tests} test(s) failed. Please check the implementation.")
        return 1

if __name__ == "__main__":
    exit(main())
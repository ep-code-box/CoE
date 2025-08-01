#!/usr/bin/env python3
import requests
import json

response = requests.get("http://localhost:8000/openapi.json")
data = response.json()

print("=== CoE-Backend API 엔드포인트 목록 ===")
for path in sorted(data['paths'].keys()):
    methods = list(data['paths'][path].keys())
    print(f"{path} - {', '.join(methods).upper()}")

print("\n=== 임베딩 관련 엔드포인트 검색 ===")
embedding_paths = [path for path in data['paths'].keys() if 'embed' in path.lower()]
if embedding_paths:
    print("임베딩 엔드포인트 발견:")
    for path in embedding_paths:
        print(f"  {path}")
else:
    print("임베딩 엔드포인트가 없습니다.")
    
print("\n=== 벡터 관련 엔드포인트 검색 ===")
vector_paths = [path for path in data['paths'].keys() if 'vector' in path.lower()]
if vector_paths:
    print("벡터 엔드포인트 발견:")
    for path in vector_paths:
        methods = list(data['paths'][path].keys())
        print(f"  {path} - {', '.join(methods).upper()}")
else:
    print("벡터 엔드포인트가 없습니다.")
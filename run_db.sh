#!/bin/bash

# DB와 임베딩 모델만 실행하는 스크립트
# - chroma: 벡터 데이터베이스 (포트 6666)
# - mariadb: 관계형 데이터베이스 (포트 6667)  
# - koEmbeddings: 한국어 임베딩 서비스 (포트 6668)

echo "🚀 DB와 임베딩 서비스를 시작합니다..."
docker-compose up -d chroma mariadb koEmbeddings

echo "✅ 서비스 시작 완료!"
echo "📊 실행 중인 서비스:"
echo "  - ChromaDB: http://localhost:6666"
echo "  - MariaDB: localhost:6667"
echo "  - Korean Embeddings: http://localhost:6668"

echo ""
echo "📋 서비스 상태 확인:"
docker-compose ps chroma mariadb koEmbeddings
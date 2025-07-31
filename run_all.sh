#!/bin/bash

# CoE 전체 시스템 실행 스크립트
# 이 스크립트는 모든 서비스를 Docker Compose로 실행합니다.

echo "🚀 CoE 시스템을 시작합니다..."

# 환경 변수 파일 확인
echo "📋 환경 변수 파일을 확인합니다..."

if [ ! -f "CoE-Backend/.env" ]; then
    echo "⚠️  CoE-Backend/.env 파일이 없습니다."
    if [ -f "CoE-Backend/.env.example" ]; then
        echo "📝 .env.example을 복사하여 .env 파일을 생성합니다..."
        cp CoE-Backend/.env.example CoE-Backend/.env
        echo "✅ CoE-Backend/.env 파일이 생성되었습니다. 필요한 값들을 설정해주세요."
    else
        echo "❌ .env.example 파일도 없습니다. 수동으로 .env 파일을 생성해주세요."
    fi
fi

if [ ! -f "CoE-RagPipeline/.env" ]; then
    echo "⚠️  CoE-RagPipeline/.env 파일이 없습니다."
    if [ -f "CoE-RagPipeline/.env.example" ]; then
        echo "📝 .env.example을 복사하여 .env 파일을 생성합니다..."
        cp CoE-RagPipeline/.env.example CoE-RagPipeline/.env
        echo "✅ CoE-RagPipeline/.env 파일이 생성되었습니다."
    else
        echo "❌ .env.example 파일도 없습니다. 수동으로 .env 파일을 생성해주세요."
    fi
fi

# 필요한 디렉토리 생성
echo "📁 필요한 디렉토리를 생성합니다..."
mkdir -p db/chroma db/maria db/koEmbeddings
mkdir -p CoE-Backend/flows
mkdir -p CoE-RagPipeline/output CoE-RagPipeline/chroma_db

# Docker Compose로 모든 서비스 실행
echo "🐳 Docker Compose로 모든 서비스를 시작합니다..."
docker-compose up -d --build

# 서비스 상태 확인
echo "⏳ 서비스가 시작될 때까지 잠시 기다립니다..."
sleep 10

echo "📊 서비스 상태를 확인합니다..."
docker-compose ps

echo ""
echo "🎉 CoE 시스템이 시작되었습니다!"
echo ""
echo "📍 서비스 접속 정보:"
echo "   - CoE-Backend (AI 에이전트): http://localhost:8000"
echo "   - CoE-RagPipeline (분석 엔진): http://localhost:8001"
echo "   - ChromaDB: http://localhost:6666"
echo "   - MariaDB: localhost:6667"
echo "   - Korean Embeddings: http://localhost:6668"
echo ""
echo "📝 로그 확인: docker-compose logs -f"
echo "🛑 시스템 중지: docker-compose down"
echo ""
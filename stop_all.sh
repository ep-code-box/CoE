#!/bin/bash

# CoE 전체 시스템 중지 스크립트

echo "🛑 CoE 시스템을 중지합니다..."

# Docker Compose로 모든 서비스 중지
docker-compose down

echo ""
echo "🧹 완전 정리를 원하시나요? (볼륨과 이미지까지 삭제)"
echo "1) 일반 중지 (데이터 보존)"
echo "2) 볼륨까지 삭제 (데이터 삭제)"
echo "3) 볼륨과 이미지까지 삭제 (완전 정리)"
echo ""
read -p "선택하세요 (1-3, 기본값: 1): " choice

case $choice in
    2)
        echo "🗑️  볼륨까지 삭제합니다..."
        docker-compose down -v
        ;;
    3)
        echo "🗑️  볼륨과 이미지까지 삭제합니다..."
        docker-compose down -v --rmi all
        ;;
    *)
        echo "✅ 일반 중지가 완료되었습니다. 데이터는 보존됩니다."
        ;;
esac

echo ""
echo "✅ CoE 시스템이 중지되었습니다."
echo ""
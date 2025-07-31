# KoSentenceBERT-ETRI Docker Image
FROM python:3.8-slim

# 작업 디렉토리 설정
WORKDIR /app

# 시스템 패키지 업데이트 및 git 설치
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# BM-K/KoSentenceBERT-ETRI 저장소 클론
RUN git clone https://github.com/BM-K/KoSentenceBERT-ETRI.git .

# 필요한 Python 패키지 설치
# transformers 2.4.1-2.8.0, sentence-transformers 3.1.0+ 요구사항에 맞춰 설치
RUN pip install --no-cache-dir \
    transformers==2.8.0 \
    sentence-transformers>=3.1.0 \
    torch \
    numpy \
    scikit-learn

# 포트 노출 (API 서버용)
EXPOSE 8080

# 기본 명령어 (Python 인터프리터 실행)
CMD ["python", "-c", "print('KoSentenceBERT-ETRI is ready'); import time; time.sleep(3600)"]
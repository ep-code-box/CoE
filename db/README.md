# CoE 데이터베이스 스키마 및 마이그레이션

CoE 프로젝트의 데이터베이스 스키마 정의 및 마이그레이션 스크립트들을 관리하는 디렉토리입니다.

## 📂 디렉토리 구조

```
db/
├── init/                           # 초기 데이터베이스 설정
│   ├── 01_create_database.sql      # 데이터베이스 및 사용자 생성
│   ├── 02_create_tables.sql        # 기본 테이블 생성
│   ├── 03_insert_sample_data.sql   # 샘플 데이터 삽입
│   ├── 04_add_missing_tables.sql   # 누락된 테이블 추가 ⭐ NEW
│   └── 05_create_langflows_table.sql # LangFlow 워크플로우 테이블 추가 ⭐ NEW
├── migrate/                        # 마이그레이션 스크립트
│   ├── 001_initial_schema.sql      # 초기 스키마 마이그레이션
│   ├── 002_create_auth_tables.sql  # 인증 테이블 생성
│   ├── 003_add_missing_tables.sql  # 누락된 테이블 추가 ⭐ NEW
│   └── migrate.py                  # 마이그레이션 실행 스크립트
├── migrate.py                      # 메인 마이그레이션 스크립트
└── README.md                       # 현재 파일
```

## 🗄️ 데이터베이스 스키마 개요

### 📊 전체 테이블 목록

| 테이블명 | 설명 | 상태 |
|---------|------|------|
| **인증 및 사용자 관리** |
| `users` | 사용자 정보 | ✅ |
| `user_roles` | 사용자 역할 정의 | ✅ |
| `user_role_mappings` | 사용자-역할 매핑 | ✅ |
| `refresh_tokens` | 리프레시 토큰 | ✅ |
| **채팅 및 대화** |
| `chat_messages` | 채팅 메시지 히스토리 | ⭐ NEW |
| `conversation_summaries` | 대화 세션 요약 | ⭐ NEW |
| `user_sessions` | 사용자 세션 | ✅ |
| **분석 및 레포지토리** |
| `analysis_requests` | 분석 요청 | ✅ |
| `repository_analyses` | 레포지토리 분석 결과 | ✅ (commit 정보 추가) |
| `code_files` | 코드 파일 정보 | ✅ |
| `ast_nodes` | AST 노드 | ✅ |
| `tech_dependencies` | 기술 의존성 | ✅ |
| `correlation_analyses` | 연관도 분석 | ✅ |
| `document_analyses` | 문서 분석 | ✅ |
| **문서 생성** |
| `document_generation_tasks` | 문서 생성 작업 추적 | ⭐ NEW |
| `generated_documents` | 생성된 문서 정보 | ⭐ NEW |
| **기타** |
| `langflows` | LangFlow 워크플로우 | ✅ |
| `vector_embeddings` | 벡터 임베딩 메타데이터 | ✅ |
| `development_standards` | 개발 표준 문서 | ✅ |
| `api_logs` | API 호출 로그 | ✅ |
| `rag_analysis_results` | RAG 분석 결과 (백워드 호환) | ✅ |
| `system_settings` | 시스템 설정 | ⭐ NEW |
| `schema_migrations` | 마이그레이션 메타데이터 | ✅ |

### 🆕 새로 추가된 테이블들

#### 1. LangFlow 워크플로우 관련
- **`langflows`**: LangFlow 워크플로우 정의 및 메타데이터 저장

#### 2. 채팅 히스토리 관련
- **`chat_messages`**: 사용자와 AI 간의 모든 채팅 메시지 저장
- **`conversation_summaries`**: 3턴 멀티턴 대화 지원을 위한 세션별 요약

#### 3. 문서 생성 관련
- **`document_generation_tasks`**: LLM 기반 문서 생성 작업의 상태 추적
- **`generated_documents`**: 생성된 문서 파일의 메타데이터

#### 4. 시스템 관리
- **`system_settings`**: 시스템 전반의 설정값 관리

#### 5. 기존 테이블 확장
- **`repository_analyses`**: commit 정보 필드 추가 (commit_hash, commit_date, commit_author, commit_message)

## 🚀 사용 방법

### 1. 초기 데이터베이스 설정

```bash
# Docker 환경에서 MariaDB 실행 후
cd /Users/lastep/Documents/Code/CoE/db

# 1. 데이터베이스 및 사용자 생성
mysql -h localhost -P 6667 -u root -p < init/01_create_database.sql

# 2. 기본 테이블 생성
mysql -h localhost -P 6667 -u coe_user -p coe_db < init/02_create_tables.sql

# 3. 누락된 테이블 추가
mysql -h localhost -P 6667 -u coe_user -p coe_db < init/04_add_missing_tables.sql

# 4. LangFlow 워크플로우 테이블 추가
mysql -h localhost -P 6667 -u coe_user -p coe_db < init/05_create_langflows_table.sql

# 4. 샘플 데이터 삽입 (선택사항)
mysql -h localhost -P 6667 -u coe_user -p coe_db < init/03_insert_sample_data.sql
```

### 2. 마이그레이션 실행

```bash
# Python 마이그레이션 스크립트 실행
cd /Users/lastep/Documents/Code/CoE/db
python migrate.py

# 또는 migrate 디렉토리에서
cd migrate
python migrate.py
```

### 3. 환경 변수 설정

마이그레이션 실행 전에 다음 환경 변수를 설정하세요:

```bash
# .env 파일 또는 환경 변수
DB_HOST=localhost        # 또는 mariadb (Docker 환경)
DB_PORT=6667            # 또는 3306 (기본값)
DB_USER=coe_user
DB_PASSWORD=coe_password
DB_NAME=coe_db
```

## 🔍 주요 기능별 테이블 관계

### 채팅 시스템
```
user_sessions → chat_messages
user_sessions → conversation_summaries
users → chat_messages (optional)
```

### 분석 시스템
```
analysis_requests → repository_analyses → code_files → ast_nodes
analysis_requests → correlation_analyses
repository_analyses → tech_dependencies
repository_analyses → document_analyses
```

### 문서 생성 시스템
```
analysis_requests → document_generation_tasks → generated_documents
```

### 인증 시스템
```
users → user_role_mappings → user_roles
users → refresh_tokens
```

## 📋 체크리스트

### ✅ 완료된 항목
- [x] 기본 테이블 스키마 정의
- [x] 사용자 인증 테이블
- [x] 분석 관련 테이블
- [x] 마이그레이션 시스템 구축

### ⭐ 새로 추가된 항목
- [x] 채팅 히스토리 테이블
- [x] 대화 세션 요약 테이블
- [x] 문서 생성 작업 추적 테이블
- [x] 생성된 문서 메타데이터 테이블
- [x] 시스템 설정 테이블
- [x] repository_analyses에 commit 정보 추가

## 🔧 문제 해결

### 마이그레이션 실패 시
1. 데이터베이스 연결 확인
2. 권한 확인 (coe_user가 모든 권한을 가지고 있는지)
3. 기존 테이블과의 충돌 확인
4. 로그 확인 후 수동으로 문제 해결

### 테이블 누락 시
1. `04_add_missing_tables.sql` 실행
2. 또는 `003_add_missing_tables.sql` 마이그레이션 실행
3. 애플리케이션 재시작

## 📝 참고사항

- 모든 테이블은 `utf8mb4` 문자셋 사용
- 외래 키 제약조건으로 데이터 무결성 보장
- 인덱스 최적화로 쿼리 성능 향상
- JSON 컬럼 활용으로 유연한 데이터 구조 지원
- 백워드 호환성을 위한 `rag_analysis_results` 테이블 유지
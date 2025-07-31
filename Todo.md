## 📋 CoE 플랫폼 개발 로드맵

### 🎯 다음 목표 (Next Sprint)

#### CoE-RagPipeline
- [ ] **DB 영속성 완전 통합**: 분석 결과를 파일이 아닌 MariaDB에 저장하고 조회하도록 `main.py` 로직 수정
- [ ] **문서 자동 수집 기능**: `README` 외에 `docs/` 폴더 등 다른 문서 파일들을 수집하여 임베딩하는 로직 추가
- [ ] **정적 분석 고도화**: AST 분석 결과를 더 의미 있는 정보(예: 함수별 설명, 클래스 구조)로 가공하여 임베딩

#### CoE-Backend
- [ ] **DB 서비스 확장**: `guide_extraction_tool`이 RAG 검색 외에 MariaDB의 분석 메타데이터도 활용하도록 개선
- [ ] **사용자 피드백 루프 구현**: 생성된 가이드에 대해 사용자가 평가할 수 있는 API 및 DB 모델 추가

#### 시스템 전반
- [ ] **서비스 간 인증**: `CoE-Backend`와 `CoE-RagPipeline` 간 API 호출에 API 키 인증 적용

---

### ✅ 완료 (Done)

#### CoE Backend
- [X] **LangGraph 에이전트 아키텍처 구현**: 동적 도구 라우팅 및 자동 등록 기능 구현 완료
- [X] **OpenWebUI 호환 API 구현**: `/v1/chat/completions`, `/v1/models` 엔드포인트 구현 완료
- [X] **RAG 기반 가이드 추출 도구**: `guide_extraction_tool`이 `CoE-RagPipeline`의 검색 API를 사용하도록 개선 완료
- [X] **MariaDB 연동 (LangFlow)**: LangFlow 데이터 저장을 위한 DB 서비스 및 API 구현 완료

#### CoE RagPipeline
- [X] **Git 레포지토리 분석 파이프라인**: AST, 기술 스택 등 정적 분석 기능 구현 완료
- [X] **Embedding 및 벡터 검색**: 분석 결과를 ChromaDB에 임베딩하고, `/search` API를 통해 검색하는 기능 구현 완료
- [X] **DB 모델 정의**: MariaDB에 분석 결과를 저장하기 위한 SQLAlchemy 모델(`RagAnalysisResult`) 정의 완료

---

### 🔮 장기 고려사항 (Future)

#### 시스템 아키텍처
- [ ] **비동기 워크플로우 도입**: 분석 완료 시 Polling 대신 Webhook 또는 메시지 큐(RabbitMQ 등)로 통지
- [ ] **데이터 생명주기 관리**: 오래된 분석/벡터 데이터 자동 아카이빙 또는 삭제 정책 구현

#### 기능 고도화
- [ ] **Private Git Repository 지원**: Git 토큰/SSH 키를 안전하게 관리하고 사용하는 기능 추가
- [ ] **RAG 성능 개선**: 검색 결과 재랭킹(Re-ranking), 하이브리드 검색 등 도입
- [ ] **멀티모달 지원**: 이미지, 다이어그램 등 비-텍스트 데이터 분석 및 검색 기능 고려
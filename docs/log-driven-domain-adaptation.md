# 로그 기반 도메인 지식 LLM 강화 아키텍처

본 문서는 사용자 상호작용 로그를 활용해 대규모 언어 모델(LLM)이 특정 도메인을 심층 이해하도록 만드는 경량 아키텍처를 설명합니다. 핵심 목표는 전체 재학습 없이 반복 학습 루프를 구성하고, 공용 지식과 그룹별(private) 지식을 안전하게 병행하는 것입니다.

## 구성 요소 개요
- **CoE-Backend**: 사용자 요청, 응답, 피드백, 실행 성공 여부를 `events/{date}/interactions.jsonl` 형태로 기록합니다. 수집 직후 PII 필터를 통해 민감 정보가 제거된 스트림을 Kafka 또는 Redis Streams로 전달합니다. 이벤트에는 `group_name`, `user_id`, `intent`, `success`를 포함해 다중 테넌트 맥락을 유지합니다.
- **CoE-Agent**: 소비 큐를 구독하는 비동기 에이전트를 모읍니다.
  - `SessionSummarizerAgent`: 세션 요약/의도/미해결 항목을 추출하고 공용·그룹별 버전을 모두 작성합니다.
  - `KnowledgeDistillerAgent`: 반복되는 Q&A·절차·주의사항을 지식 카드로 변환하며, 카드에 `scope=global|group` 메타를 부여합니다.
  - `IssueReplayAgent`: 실패 이벤트를 재현해 분석 큐에 넣고, 민감도가 높은 로그는 그룹 전용 저장소에만 남깁니다.
- **CoE-RagPipeline**: 에이전트가 생성한 지식 카드와 원본 스니펫을 `knowledge_base` 테이블(메타데이터)과 벡터 인덱스(pgvector, Milvus 등)에 저장합니다. 인덱스는 `global_index`와 `group/<group_name>` 네임스페이스로 분리되며, 최신성·신뢰도·민감도 점수를 관리합니다.

## 데이터 흐름
1. **이벤트 적재**: Backend가 이벤트를 스트림과 일별 JSONL로 동시에 남깁니다. 이벤트 키는 `(<group_name>, <session_id>)`로 구성해 파티셔닝합니다.
2. **요약 파이프라인**: CoE-Agent가 이벤트를 받아 세션 요약, FAQ, 실패 케이스를 생성합니다. 그룹 범위 요약물은 해당 그룹 네임스페이스로만 전파합니다.
3. **지식 축적**: Distiller 출력은 벡터 DB에 인덱싱되며, 메타데이터에 `scope`, `group_name`, `source`, `quality_score`, `feedback_count`를 저장해 추후 필터링을 가능하게 합니다.
4. **RAG 호출**: 질의가 들어오면 오케스트레이터가 공용 카드(Global Layer)와 요청자의 `group_name` 카드(Group Layer)를 각각 조회합니다. 결과는 `context_window = global_topk + group_topk + session_memory` 순으로 병합하고, 중복을 제거해 프롬프트를 구성합니다.
5. **피드백 루프**: 응답에는 `confidence`, `supporting_snippets`, `memory_refs`, `knowledge_scope`(global/group)를 포함해 추가 학습 자료로 활용합니다. 그룹 전용 응답은 감사 로그에도 `group_name`을 명시합니다.

### 지식 레이어 매핑
| 레이어 | 주요 콘텐츠 | 저장소/인덱스 | 접근 정책 | 갱신 주기 |
| --- | --- | --- | --- | --- |
| Global Layer | 공용 FAQ, 절차, 규정 | `knowledge_base.global` + `global_index` | 모든 테넌트 조회 가능 | 매 배치(시간/일 단위) |
| Group Layer | 특정 그룹 업무 매뉴얼, 예외 처리 | `knowledge_base.<group>` + `group/<group_name>` | 해당 그룹 토큰만 조회 | 이벤트 중심(실시간) |
| Session Memory | 최근 대화 요약, 미해결 이슈 | Redis/Key-Value 캐시 | 세션 토큰 보유 사용자 | 세션 단위 |
| Issue Queue | 실패 재현, 에러 추적 | ClickHouse/S3 로그 | 운영 팀 전용 | 주간 검토 |

## 운영 및 품질 관리
- **프롬프트 관리**: 도메인·그룹 조합별 템플릿을 `templates/<domain>/<scope>/v*.json`으로 버전 관리합니다. 변경 시 A/B 로그를 비교해 성능과 개인정보 누출 여부를 검증합니다.
- **품질 측정**: 카드 재사용률, 성공률, 사용자 피드백을 주간 리포트로 시각화하고, 그룹별 히트율을 별도로 집계해 공용 지식으로 승격해야 할 후보를 찾습니다.
- **보관 정책**: 오래되거나 재사용률이 낮은 카드에는 만료 태그를 붙이고, 공용 전환이 필요한 그룹 카드에는 승인 워크플로를 거쳐 `global_index`로 승격합니다.
- **접근 제어**: RAG 파이프라인과 백엔드는 `group_name`을 토큰 클레임 또는 세션 메타로 검증합니다. 벡터 DB에는 그룹 네임스페이스별 ACL을 설정해 엑세스 범위를 제한합니다.
- **확장 로드맵**: 인증·재시도·스트리밍 응답이 필요한 경우 `RagClient`를 확장하고, 충분한 데이터가 쌓이면 LoRA 같은 경량 미세 조정으로 도메인별 전담 모델을 추가합니다.

이 구조를 통해 전체 모델 재학습 비용 없이도 로그 기반 지식 축적과 실시간 RAG 강화를 결합하고, 공용·그룹 전용 지식을 동시에 관리하여 도메인 이해도를 지속적으로 높일 수 있습니다.

### 엔드-투-엔드 흐름 요약
```mermaid
flowchart TD
    A[사용자 요청] --> B[CoE-Backend<br/>로그 수집 & PII 필터]
    B -->|events/{date}/interactions.jsonl<br/>(group_name, intent, success)| C[이벤트 스트림<br/>Kafka / Redis Streams]
    C --> D[CoE-Agent 에이전트]
    D --> D1[SessionSummarizerAgent<br/>세션 요약, 미해결]
    D --> D2[KnowledgeDistillerAgent<br/>지식 카드 생성<br/>scope=global/group]
    D --> D3[IssueReplayAgent<br/>실패 분석 큐]
    D1 --> E[지식 저장소]
    D2 --> E
    D3 --> F[Issue Queue<br/>운영 점검]
    E -->|knowledge_base.global / group/&lt;group_name&gt;| G[벡터 인덱스<br/>global_index &amp; group 네임스페이스]
    G --> H[CoE-RagPipeline 검색]
    H --> H1[Global Layer Top-K]
    H --> H2[Group Layer Top-K]
    H --> H3[Session Memory]
    H1 --> I[LLM 프롬프트 조립 & 응답]
    H2 --> I
    H3 --> I
    I --> J[confidence, supporting_snippets, knowledge_scope]
    J --> K[피드백 / 감사 로그]
    K --> B
```

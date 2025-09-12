**목적**
- 요청의 `group_name`을 `context`와 함께 추가 필터로 사용하여, 도구/플로우 후보를 더 정밀하게 제한하는 설계를 정의합니다. 기존 동작은 깨지지 않도록 하며, 변경 범위를 최소화합니다.

**목표**
- `group_name`이 있을 때만 선택적으로 필터링을 적용합니다.
- `group_name`이 없을 때는 현재와 동일하게 동작합니다(완전 하위 호환).
- LLM 우선(LLM-first) 인자 추출과 자연스러운 출력 포맷 원칙을 유지합니다.
- 코드 변경을 최소화하고, LangFlow 매핑은 무마이그(스키마 변경 없이) 경로를 우선 제공합니다.

**비목표**
- 권한/인가(Access Control) 자체는 범위에 포함하지 않습니다. 본 설계의 필터링은 UX 스코프(노출 제한)를 위한 것입니다.

**API 계약**
- `OpenAIChatRequest`에는 이미 선택적 `group_name` 필드가 있습니다.
- 동작: `group_name`이 제공되면, 컨텍스트로 모은 후보에서 추가로 그룹 기준 필터링을 적용합니다. 후보가 없으면 안전한 폴백을 수행합니다.

**설계 개요**
- 필터링은 “후보 수집 단계”에서 적용합니다.
  - Python 도구: 컨텍스트별 도구 스키마/함수 로딩 시 그룹 제한 적용.
  - LangFlow 플로우: 현재 컨텍스트 허용 여부를 판단할 때 그룹 기준도 함께 검증.
- 실행/포맷/LLM 인자 생성 로직은 변경하지 않습니다.

**Python 도구 필터링**
- 각 `*_map.py`에 선택적으로 `allowed_groups: List[str]`를 선언할 수 있습니다.
  - 선언 없음: 모든 그룹에 노출(하위 호환).
  - 선언 있음: 요청 `group_name`이 `allowed_groups`에 포함될 때만 노출.
- `*_tool.py`의 계약(run, 반환형 등)은 변경하지 않습니다.

**LangFlow 플로우 필터링**
- 두 가지 구현 옵션:
  - 옵션 A(권장, 무마이그): `langflow_tool_mappings.context`에 복합 키(`컨텍스트:그룹`)를 저장/인식합니다.
    - 허용 판정 시 `context`와 `"{context}:{group_name}"` 둘 중 하나라도 매칭되면 허용합니다.
    - 특정 그룹으로 제한하고 싶다면, 예: `aider:dev-team` 형태로 매핑 레코드를 추가합니다.
  - 옵션 B(마이그 필요): `langflow_tool_mappings`에 `group_name` 컬럼을 추가합니다.
    - (flow_id, context, group_name) 조합으로 판정하며, `group_name=NULL`은 전체 그룹 허용 의미로 사용합니다.
    - Alembic 마이그레이션과 CRUD 수정이 필요합니다.
- 권장안: 옵션 A로 무마이그 릴리스 → 필요 시 옵션 B 전환 검토.

**제어 플래그(Feature Flag)**
- `ENABLE_GROUP_FILTERING` (기본: true)
  - true: `group_name`이 있을 때 그룹 필터링을 적용.
  - false: 그룹 필터를 완전히 무시(신속 롤백 스위치).

**실패/폴백 동작**
- `group_name` 기준으로 남는 후보가 0개인 경우:
  - 폴백 1: 컨텍스트만 기준으로 다시 후보를 사용(그룹 무시).
  - 폴백 2: 선제 자동 라우팅을 생략하고, 모델의 일반 tool_call 흐름에 맡깁니다.
- 모든 경우, 사용자 출력은 자연스러운 단문을 유지합니다.

**로깅/관측(Observability)**
- 필터링 컨텍스트와 그룹, 후보 개수(필터 전/후), 스킵 사유를 로그에 남깁니다.
- API 호출 로그에도 `group_name` 태그를 추가해 디버깅 용이성을 확보합니다.

**테스트 계획**
- 단위(Unit)
  - 맵 로더가 `allowed_groups`에 따라 도구를 필터링하는지 검증.
  - 플로우 허용 검사에서 `context`와 `context:group` 복합 키 모두 인식되는지 검증.
- 통합(Integration)
  - `group_name` 유/무에 따른 후보 노출 차이 확인.
  - 후보 0개 시 폴백 동작 확인.
- E2E(curl)
  - 동일 질의에 대해 `group_name` 제공/비제공 시 결과가 달라지는지 확인.

**마이그레이션 계획**
- 1단계(무마이그):
  - LangFlow 매핑에 복합 키(`context:group`) 패턴 채택.
  - Python 도구 중 제한이 필요한 맵에만 `allowed_groups` 추가.
- 2단계(선택):
  - `langflow_tool_mappings`에 `group_name` 컬럼 추가(Alembic).
  - 기존 복합 키를 구조화된 컬럼으로 백필, 호환 레이어(옵션) 유지.

**롤아웃 단계**
- 1) 플래그 및 필터 로직 구현(비활성 상태에서 테스트 가능하도록)
- 2) 일부 도구 맵에 `allowed_groups` 추가, LangFlow 매핑에 샘플 복합 키 추가
- 3) 개발 환경 검증(`group_name` 샘플: `dev-team`, `alpha` 등)
- 4) 스테이징 적용 후 로그/후보 수 모니터링
- 5) 프로덕션 적용

**코드 변경 지점(최소)**
- 맵 로더: `get_available_tools_for_context(context, group_name)`
  - `*_map.py`의 `allowed_groups`(선택)를 읽어 그룹 필터 적용
- 플로우 허용 판정: `_flow_allowed_in_context(db, flow, context, group_name)`
  - `context` 또는 `"context:group"` 키 허용(옵션 A)
- 호출부: `group_name` 전달만 추가
  - `api/chat_api.py`, `core/agent_nodes.py`

**호환성/안전성**
- 기존 도구/플로우는 아무 변경 없이 그대로 동작합니다.
- `group_name`이 제공된 요청에서만 후보가 좁혀지며, 항상 안전한 폴백이 존재합니다.
- 문제가 있을 경우 `ENABLE_GROUP_FILTERING=false`로 즉시 비활성화 가능합니다.

**오픈 이슈**
- 그룹별 우선순위(랭크 보정) 필요 여부
- `group_name` 값에 대한 사전 등록/검증 필요 여부(오타 방지)
- 사용자 응답에 “적용된 그룹” 정보를 노출할지 여부(투명성)


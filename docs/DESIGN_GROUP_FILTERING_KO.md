**목적**
- `group_name`과 `context`를 함께 사용하여 도구/플로우 후보를 정확히 제한하는, 마이그레이션 기반의 확정적 설계를 제시합니다.

**목표**
- `group_name`이 있을 때 정확한 필터링을 적용하고, 없을 때는 공용(public) 항목만 노출합니다.
- LLM-first 인자 추출과 자연스러운 출력은 유지합니다.
- 스키마 구조화를 우선하되, 무중단 전환을 위해 임시 호환 레이어를 제공합니다.

**비목표**
- 권한/인가 기능은 범위 밖입니다. 본 필터링은 노출 범위 제한(UX)입니다.

**API 계약**
- `OpenAIChatRequest.group_name: Optional[str]` 사용.
- 동작: `group_name`이 있으면 해당 그룹+공용 후보만, 없으면 공용 후보만 노출.
- 입력 검증: 소문자 정규화, `^[a-z0-9]([a-z0-9-_]{0,62}[a-z0-9])?$` 규칙 준수.

**데이터 모델(권장)**
- LangFlow 매핑
  - 테이블: `langflow_tool_mappings(flow_id, context, group_name NULLABLE, description, …)`
  - 의미: `group_name=NULL`은 공용(모든 그룹), 값이 있으면 해당 그룹 전용.
  - 인덱스: `(flow_id, context, group_name)`, 보조로 `(context, group_name)`.
  - 제약: `(flow_id, context, group_name)` 조합이 중복되지 않도록 유지합니다. MySQL 호환을 위해 (a) 애플리케이션 레벨에서 중복 삽입을 차단하거나 (b) `COALESCE(group_name,'')` 값을 생성 컬럼으로 만들어 해당 컬럼에 유니크 인덱스를 적용하는 방식을 배포 환경에 맞춰 선택합니다.
- Python 도구(모듈 메타데이터)
  - 모듈 전역 `allowed_groups: List[str]`(맵 내 전체 도구 공통 제한).
  - 선택적 `allowed_groups_by_tool: Dict[str, List[str]]`(도구별 세분화).
  - 둘 다 없으면 공용으로 간주.
- 선택: 그룹 레지스트리
  - `groups(name PK, display_name, is_active)`로 값 검증/관리. 필수는 아님.

**매칭 규칙**
- Python 도구
  - `group_name` 없음: 공용 도구만 포함(어떤 `allowed_groups*`라도 있으면 제외).
  - `group_name` 있음: 다음 중 하나면 포함
    - `allowed_groups_by_tool[name]`에 그룹이 있음
    - 모듈 전역 `allowed_groups`에 그룹이 있음
    - 어떠한 `allowed_groups*` 도 선언되지 않음(공용)
  - `allowed_groups*`가 선언되어 있는데 그룹이 불일치하면 제외.
- LangFlow 플로우
  - `group_name` 없음: `(flow_id, context, group_name IS NULL)` 행이 있으면 허용.
  - `group_name` 있음: `(flow_id, context, group_name=:group)` 또는 `(flow_id, context, group_name IS NULL)` 중 하나라도 있으면 허용.
  - 두 행이 모두 존재하면 `(context, group_name)` 매핑을 우선 선택하고, 공용 `(context, NULL)` 행은 fallback 용도로 유지합니다.
  - 공용(NULL) 행은 여전히 그룹 미지정 요청을 위한 기본값입니다.

**폴백 정책(엄격·안전)**
- `group_name`이 있고 결과가 0개일 때:
  - 제한을 무시하지 않습니다.
  - Python 도구: 공용 도구만 고려합니다(`allowed_groups*` 미선언).
  - LangFlow: 공용 행(`group_name IS NULL`)만 고려합니다.
  - 그래도 0개면, 선제 자동 라우팅을 생략하고 모델의 일반 tool_call 흐름에 맡깁니다.
- `group_name`이 없을 때: 공용 후보만 사용합니다.

**제어 플래그**
- `ENABLE_GROUP_FILTERING` (기본: false)
  - true: 본 문서 규칙을 적용.
  - false: 그룹 필터를 완전히 무시(완전 하위 호환). 롤백 스위치로 사용.

**정규화/검증**
- 요청 진입 시 소문자 정규화/트림.
- `:`/공백 금지, 길이 1–64. 위의 정규식 준수.
- 레지스트리 사용 시: 미등록/비활성 그룹은 400. 없으면 “매칭 0→공용 폴백”으로 처리.

**로깅/관측**
- 후보 수집 단계에서 구조화 로그: `context`, `group_name`, 전/후 카운트, 스킵 사유.
- 필요 시 `api_logs` 컬럼 추가 또는 `chat_messages.tool_metadata`에 `group_name` 포함.
- 메트릭: `tools.candidates.*`, `flows.candidates.*`에 `context`, `group` 라벨 부여.

**마이그레이션 계획(구조화 우선)**
- 0단계: `ENABLE_GROUP_FILTERING=false` 상태로 코드 경로 도입(현행 유지).
- 1단계: Alembic
  - `langflow_tool_mappings`에 `group_name`(NULL 허용) 추가.
  - 인덱스/유니크 제약 추가.
  - 선택: `groups` 테이블 추가 및 시드.
- 2단계: 데이터 백필/호환
  - 기존 `context:group` 복합 키가 있으면 `(context, group_name)`으로 분리 삽입.
  - 일정 기간 읽기 시 복합 키도 허용(감쇠 경로).
- 2.5단계: 쓰기 경로 확장
  - `FlowCreate`/`FlowUpdate` 스키마와 `/flows/save` 핸들러에 `(context, allowed_groups)` 입력을 받아 API로 그룹별 매핑을 등록합니다.
  - 필요 시 관리용 CLI 또는 어드민 API로 `(context, group_name)` 행을 직접 upsert하는 유틸을 제공합니다.
- 3단계: dev/staging에서 플래그 on, 로그/카운트 검증.
- 4단계: 복합 키 읽기 제거 및 데이터 정리, 프로덕션 활성화.

**롤아웃 단계**
- 디스패처/허용 검사에 플래그+필터링 구현.
- 필요한 도구 맵에 `allowed_groups`/`allowed_groups_by_tool` 설정.
- LangFlow 매핑에 공용/그룹 전용 행 시드(필요 시 복합 키에서 백필).
- LangFlow CRUD 경로를 갱신해 운영자가 DB를 직접 만지지 않고 `group_name`을 관리할 수 있게 합니다.
- dev/staging 검증 후 프로덕션 전환.

**코드 변경 지점**
- 디스패처 시그니처
  - `get_available_tools_for_context(context, group_name, enable_group_filtering)`
  - `_flow_allowed_in_context(db, flow, context, group_name, enable_group_filtering)`
- 호출부 전달
  - `api/chat_api.py`, `core/agent_nodes.py`에서 `group_name`/플래그 전달.
- 맵 메타데이터
  - `allowed_groups`와 `allowed_groups_by_tool`(선택)을 인식.
- LangFlow 실행 경로
  - `services/tool_dispatcher.find_langflow_tool`, `tools/langflow_tool.py`(`list_langflows_run`, `execute_langflow_run`), 자동 라우팅 헬퍼(`maybe_execute_best_tool*`)에서 동일한 `(context, group_name)` 필터링을 적용합니다.

**호환성/폐기**
- 플래그 off: 현행과 동일.
- 마이그 기간: 구조화/복합 키를 모두 허용하여 무중단 전환.
- 폐기 완료: 구조화 `(context, group_name)`만 사용. 복합 키 제거.

**테스트 계획**
- 단위
  - 모듈/도구별 `allowed_groups*` 우선순위, 공용/제한 동작.
  - 플로우 허용: `(context, NULL)`과 `(context, group)` 매칭.
  - 정규화: 잘못된/대소문자 혼합 `group_name` 처리.
- 통합
  - `group_name` 유무에 따라 후보가 기대대로 달라짐.
  - 0건 시 공용만 폴백.
  - 플래그 off 시 기존과 동일.
- E2E(curl)
  - 동일 질의에 대해 `group_name` 제공/비제공 케이스 비교.

**오픈 이슈**
- 그룹별 가중치(랭킹 보정) 필요 여부.
- 그룹 레지스트리/관리 UI 도입 여부.
- API 응답에 적용 그룹 표시(header 등) 여부.

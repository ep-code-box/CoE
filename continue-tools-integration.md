## Continue 내장 Tools 연동 가이드

### 1. Continue → Backend: 요청 형식

OpenAI Chat Completions 규격으로 tools 배열과 tool_choice를 포함합니다. 아래는 예시입니다.

```json
{
  "model": "your-model",
  "messages": [
    { "role": "system", "content": "assistant behavior ..." },
    { "role": "user", "content": "프로젝트 디렉토리 파일 목록 보여줘" }
  ],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "ls",
        "description": "List files in a directory",
        "parameters": {
          "type": "object",
          "required": ["path"],
          "properties": {
            "path": { "type": "string", "description": "directory path" }
          }
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "run_terminal_command",
        "description": "Run a terminal command in the current directory.",
        "parameters": {
          "type": "object",
          "required": ["command"],
          "properties": {
            "command": { "type": "string" },
            "waitForCompletion": {
              "type": "boolean",
              "description": "default true; false면 백그라운드 실행"
            }
          }
        }
      }
    }
  ],
  "tool_choice": "auto",
  "stream": false
}
```

- 내장 툴 이름(함수명)은 아래의 정확한 식별자를 사용해야 합니다.
  - `read_file`, `read_currently_open_file`, `create_new_file`, `edit_existing_file`, `search_and_replace_in_file`, `grep_search`, `file_glob_search`, `search_web`, `view_diff`, `ls`, `create_rule_block`, `request_rule`, `fetch_url_content`, `codebase`, `run_terminal_command`

---

### 2. Backend → Continue: 모델의 tool 호출 응답 형식

모델이 tool을 사용하려면 `assistant` 메시지의 `tool_calls`에 함수 호출을 포함해야 합니다. `arguments`는 반드시 JSON 문자열이어야 합니다.

```json
{
  "id": "chatcmpl-xxx",
  "object": "chat.completion",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": null,
        "tool_calls": [
          {
            "id": "call_abc123",
            "type": "function",
            "function": {
              "name": "run_terminal_command",
              "arguments": "{\"command\":\"npm install\",\"waitForCompletion\": true}"
            }
          }
        ]
      },
      "finish_reason": "tool_calls"
    }
  ]
}
```

스트리밍을 지원한다면 `choices[0].delta.tool_calls` 형태의 증분 델타도 허용되며, 마지막에 `finish_reason: "tool_calls"`를 반환해야 합니다.

---

### 3. Continue가 tool 실행 후 재호출하는 방식

1. Continue는 `tool_calls`를 파싱하고 해당 내장 tool을 실제로 실행합니다.
   - 예: `run_terminal_command`는 기본적으로 사용자 승인이 필요한 정책(`allowedWithPermission`)입니다.
2. 실행 결과를 role:"tool" 메시지로 첨부해 같은 모델로 다시 요청을 보냅니다.

재호출 시 `messages` 예시:

```json
{
  "model": "your-model",
  "messages": [
    { "role": "system", "content": "..." },
    { "role": "user", "content": "프로젝트 의존성 설치해줘" },
    {
      "role": "assistant",
      "content": null,
      "tool_calls": [
        {
          "id": "call_install",
          "type": "function",
          "function": {
            "name": "run_terminal_command",
            "arguments": "{\"command\":\"npm install\",\"waitForCompletion\": true}"
          }
        }
      ]
    },
    {
      "role": "tool",
      "tool_call_id": "call_install",
      "content": "added 420 packages...\n(found 0 vulnerabilities)"
    }
  ],
  "stream": false
}
```

이에 대해 모델은 최종 `assistant` 답변을 평문으로 반환합니다.

최종 응답 예시:

```json
{
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "의존성 설치가 완료되었습니다. 다음으로 빌드를 진행할까요? `npm run build`를 제안합니다."
      },
      "finish_reason": "stop"
    }
  ]
}
```

---

### 4. Continue Built-in Tools 전체 스펙

아래 항목의 "함수명(name)"은 OpenAI function calling 시 `function.name`에 그대로 사용해야 하는 식별자입니다.

#### 4.1 read_file

- 함수명: `read_file`
- 설명: 워크스페이스 루트 기준 상대 경로의 파일 내용을 읽습니다.
- 파라미터:
  - `filepath` (string, 필수): 읽을 파일 경로 (상대 경로)
- 정책: `allowedWithoutPermission`

#### 4.2 read_currently_open_file

- 함수명: `read_currently_open_file`
- 설명: IDE에서 현재 열려 있는 파일의 내용을 읽습니다.
- 파라미터: 없음
- 정책: `allowedWithPermission`

#### 4.3 create_new_file

- 함수명: `create_new_file`
- 설명: 새 파일을 생성하고 내용을 작성합니다.
- 파라미터:
  - `filepath` (string, 필수): 생성할 파일 경로 (상대 경로)
  - `contents` (string, 필수): 파일 내용
- 정책: `allowedWithPermission`

#### 4.4 edit_existing_file

- 함수명: `edit_existing_file`
- 설명: 기존 파일에 변경사항을 적용합니다. 큰 파일의 경우 변경이 없는 영역은 언어 적합한 축약 표기(예: `// ... existing code ...`)를 사용합니다.
- 파라미터:
  - `filepath` (string, 필수): 수정할 파일 경로 (상대 경로)
  - `changes` (string, 필수): 적용할 변경 텍스트(검색/치환이 아닌 최종 편집 결과)
- 정책: `allowedWithPermission`

#### 4.5 search_and_replace_in_file

- 함수명: `search_and_replace_in_file`
- 설명: 파일의 특정 구간을 SEARCH/REPLACE 블록들로 정의해 정확히 치환합니다. 병렬 호출 금지.
- 파라미터:
  - `filepath` (string, 필수)
  - `diffs` (string[] , 필수): 하나 이상의 SEARCH/REPLACE 블록 문자열 배열
- 정책: `allowedWithPermission`

#### 4.6 grep_search

- 함수명: `grep_search`
- 설명: ripgrep 정규식으로 저장소 내 텍스트 검색을 수행합니다(출력은 길이 제한 가능).
- 파라미터:
  - `query` (string, 필수): ripgrep 정규식 쿼리
- 정책: `allowedWithoutPermission`

#### 4.7 file_glob_search

- 함수명: `file_glob_search`
- 설명: 글롭 패턴으로 프로젝트 내 파일 경로를 검색합니다. `**` 재귀 패턴 지원.
- 파라미터:
  - `pattern` (string, 필수): 글롭 패턴
- 정책: `allowedWithoutPermission`

#### 4.8 search_web

- 함수명: `search_web`
- 설명: 외부 웹을 검색해 상위 결과를 반환합니다(필요 시에만 사용 권장).
- 파라미터:
  - `query` (string, 필수): 자연어 검색어
- 정책: `allowedWithoutPermission`

#### 4.9 view_diff

- 함수명: `view_diff`
- 설명: 현재 워킹 디렉토리의 git diff를 확인합니다.
- 파라미터: 없음
- 정책: `allowedWithoutPermission`

#### 4.10 ls

- 함수명: `ls`
- 설명: 지정 디렉토리의 파일/폴더 목록을 확인합니다.
- 파라미터:
  - `dirPath` (string, 선택): 루트 기준 디렉토리 경로. 기본값 권장 경로 사용 가능
  - `recursive` (boolean, 선택): 재귀 목록 여부(남용 금지)
- 정책: `allowedWithoutPermission`

#### 4.11 fetch_url_content

- 함수명: `fetch_url_content`
- 설명: URL의 웹 문서를 가져옵니다(파일 취득용 아님).
- 파라미터:
  - `url` (string, 필수)
- 정책: `allowedWithPermission`

#### 4.12 create_rule_block

- 함수명: `create_rule_block`
- 설명: 향후 대화/생성에 적용할 규칙(rule)을 생성·저장합니다. 기존 규칙 수정은 편집 도구 사용.
- 파라미터:
  - `name` (string, 필수)
  - `rule` (string, 필수)
  - `description` (string, 선택)
  - `globs` (string, 선택)
  - `regex` (string, 선택)
  - `alwaysApply` (boolean, 선택)
- 정책: `allowedWithPermission`

#### 4.13 request_rule

- 함수명: `request_rule`
- 설명: 사용 가능한 rule 목록에서 이름으로 특정 rule의 내용을 요청합니다(일부 설정에서만 노출).
- 파라미터:
  - `name` (string, 필수)
- 정책: `disabled`

#### 4.14 run_terminal_command

- 함수명: `run_terminal_command`
- 설명: 현재 디렉토리에서 터미널 명령어를 실행합니다. 셸 상태는 매 호출마다 초기화되며, 관리자 권한 작업은 금지됩니다.
- 파라미터:
  - `command` (string, 필수)
  - `waitForCompletion` (boolean, 선택, 기본 true): false면 백그라운드 실행
- 정책: `allowedWithPermission` (사용자 승인 필요)

---

"""Python tool map 예시: 특정 그룹(coe)에게만 노출되는 만 나이 계산기."""

# 도구를 사용할 수 있는 컨텍스트 목록
tool_contexts = [
    "aider",
    "continue.dev",
]

# 그룹 제한: coe 그룹에만 노출됨
allowed_groups = ["coe"]

# 엔드포인트 매핑
endpoints = {
    "calculate_international_age": "/tools/calculate-age"
}

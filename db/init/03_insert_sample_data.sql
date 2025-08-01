-- CoE 프로젝트 샘플 데이터 삽입 스크립트
USE coe_db;

-- 샘플 LangFlow 데이터
INSERT INTO langflows (name, description, flow_data) VALUES 
('sample_flow', 'Sample LangFlow for testing', '{"nodes": [{"id": "1", "type": "input", "data": {"label": "Input"}}], "edges": []}'),
('code_analysis_flow', 'Flow for code analysis tasks', '{"nodes": [{"id": "1", "type": "analyzer", "data": {"label": "Code Analyzer"}}], "edges": []}');

-- 샘플 분석 요청 데이터
INSERT INTO analysis_requests (analysis_id, status, repositories, include_ast, include_tech_spec, include_correlation) VALUES 
('550e8400-e29b-41d4-a716-446655440000', 'COMPLETED', '[{"url": "https://github.com/sample/repo1", "branch": "main"}]', true, true, false),
('550e8400-e29b-41d4-a716-446655440001', 'PENDING', '[{"url": "https://github.com/sample/repo2", "branch": "develop"}]', true, false, true);

-- 샘플 레포지토리 분석 결과
INSERT INTO repository_analyses (analysis_id, repository_url, repository_name, branch, clone_path, status, files_count, lines_of_code, languages, frameworks, dependencies) VALUES 
('550e8400-e29b-41d4-a716-446655440000', 'https://github.com/sample/repo1', 'repo1', 'main', '/tmp/repo1', 'COMPLETED', 25, 1500, '["Python", "JavaScript"]', '["FastAPI", "React"]', '["fastapi", "react", "axios"]');

-- 샘플 개발 표준 문서
INSERT INTO development_standards (analysis_id, standard_type, title, content, examples, recommendations) VALUES 
('550e8400-e29b-41d4-a716-446655440000', 'CODING_STYLE', 'Python Coding Style Guide', 'This is a sample coding style guide for Python development.', '{"naming": ["snake_case for variables", "PascalCase for classes"]}', '{"tools": ["black", "flake8", "mypy"]}');

-- 샘플 사용자 세션
INSERT INTO user_sessions (session_id, user_agent, ip_address) VALUES 
('session_123456789', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '127.0.0.1'),
('session_987654321', 'PostmanRuntime/7.29.0', '192.168.1.100');

-- 샘플 API 로그
INSERT INTO api_logs (session_id, endpoint, method, request_data, response_status, response_time_ms) VALUES 
('session_123456789', '/api/v1/analyze', 'POST', '{"repositories": [{"url": "https://github.com/sample/repo"}]}', 200, 1500),
('session_987654321', '/v1/models', 'GET', '{}', 200, 50);
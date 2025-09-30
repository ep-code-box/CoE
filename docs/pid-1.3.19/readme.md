# RELEASE NOTE
+ <a href='release_note.txt'>릴리즈노트 보기</a>

# PID 사용법 (C버젼)
+ PID(Personal Information Detector)는 입력 텍스트에서 개인정보/민감정보 스트링을 추출해주는 모듈
+ 개인정보는 숫자패턴, 행정구역명, 건물명 사전 등을 활용하여, 다음 항목을 검출
	+ 주민등록번호, 여권번호, 운전면허번호, 외국인 등록번호, 의료보험증 번호
	+ 전화번호, 계좌번호, 카드번호
	+ 주소 : 숫자로 표현되는 상세 주소가 포함된 경우만 추출 (행정구역명 + 숫자주소, 주거용건물명 + 동호수)
	+ 우편번호, 이메일주소
	+ 자동차 등록번호
	+ 사업자 등록번호
	+ 주민등록번호 앞자리 (YYMMDD)
	+ 계좌번호 앞자리 (6자리 숫자, 앞에 은행, 계좌 등의 클루가 있을 경우 추출)
+ 민감정보는 사전 매칭을 활용하여 다음 항목을 검출
	+ 종교 (불교, 기독교, ...)
	+ 정치 이념 (~주의)
	+ 노동조합, 정당명
	+ 질병 및 장애의 명칭 (조현병, 통풍, 식중독, 비문증, ...)
	+ 범죄 경력 자료 (징역, 보호관칠, 추징, ...)
+ 한글로 표현된 영문자/숫자의 처리
	+ PID는 음성인식의 요청을 고려하여, 영문자, 숫자 등이 한글로 표현된 경우를 대상으로 개발/테스트 되었음
		+ 예: 에이비씨 앳 네이버 닷컴, 삼성아파트 백구동 이백일호
	+ 영문자/숫자로 표현된 일반 텍스트에 대해서도 개발 및 기본 테스트는 수행되었음
+ 추가 정보 (EX_TYPE) 검출
	+ 개인정보로도 볼 수 있는 추가 정보를 검출
	+ 한국인명 : 중의성이 있기 때문에(예: 강동구, 홍익대), 주변 문맥을 고려하여 검출하지만, 완벽하지는 않음
	+ 행정구역명 : 2개 이상의 행정구역 단위가 연속 출현하였을 때 검출 (예: 서울시 강동구)
	+ 년월일(YEARDATE) : 의존명사 년, 월, 일 이 명시된 표현 (예: 1982년 7월 11일, 82년 7월 11일)
	+ 긴 숫자열(LONGDIGIT) : 전화번호, 주민등록번호 등이 아닌, 6자리 이상 숫자열 (중간에 공백, 대쉬 등 허용)
+ 제작: SKT AI&CO AI Intelligence Unit 지식기술Cell

# PID 성능 정보 
+ 1.3.1
	+ Normal mode
		+ 처리속도 : 116KB/sec (Intel Xeon 2.20GHz), 234KB/sec (Intel Core 4.20GHz)
		+ 사용 메모리 : 589MB (pycisal), 602KB (virtual)
	+ EX_TYPE mode (KORNAME, DISTRICT 검출, KMA 사용)
		+ 처리속도 : 47KB/sec (Intel Xeon 2.20GHz), 78KB/sec (Intel Core 4.20GHz)
		+ 사용 메모리 : 757MB (pycisal), 784MB (virtual)
+ 1.3.0
	+ Normal mode
		+ 처리속도 : 116KB/sec (Intel Xeon 2.20GHz), 180KB/sec (Intel Core 4.20GHz)
		+ 사용 메모리 : 730MB (pycisal), 743KB (virtual)
	+ EX_TYPE mode (KORNAME, DISTRICT 검출, KMA 사용)
		+ 처리속도 : 47KB/sec (Intel Xeon 2.20GHz), 71KB/sec (Intel Core 4.20GHz)
		+ 사용 메모리 : 874MB (pycisal), 914MB (virtual)
+ 1.1.0
	+ 처리속도 : 66KB/sec (Intel Xeon 2.20GHz), 130KB/sec (Intel Core 4.20GHz)
	+ 사용 메모리 : 142MB (pycisal), 154MB (virtual)

# PID 다운로드/설치
+ 패키지 다운로드 (현재 centos 7 패키지 제공)
	+ http://10.40.89.245:8111/deploy/pid/
+ pidpy (Python 패키지) 설치 (centos, macos 지원, 아래 설명은 1.3.0. 기준)
	+ whl file:
		+ pip install --extra-index-url http://10.40.89.245:8111/pypi/ --trusted-host 10.40.89.245 pidpy
	+ pkg file:
		+ (centos)
		+ wget http://10.40.89.245:8111/deploy/pidpy/pidpy-1.3.0-centos7-20220323.tar.gz
		+ tar -zxvf pidpy-1.3.0-centos7-20220323.tar.gz
		+ pip install pidpy-1.3.0-py3-none-any.whl

		+ (macos)
		+ wget http://10.40.89.245:8111/deploy/pidpy/pidpy-1.3.0-macos-20220323.tar.gz
		+ tar -zxvf pidpy-1.3.0-macos-20220323.tar.gz
		+ pip install pidpy-1.3.0-py3-none-any.whl
+ git repository
	+ git clone https://tde.sktelecom.com/stash/scm/kbtechlab/pid.git


# PID 사용방법
## API 설명
+ PID의 모든 API는 static 멤버를 호출하여, thread-safe하게 되어있음
+ int pidOpen(const string& data_path);
	+ PID 사전 로딩
		+ 멀티쓰레드일 경우, 쓰레드 앞쪽에서 한번만 호출하는 것을 권장
		+ data_path 에서 사용자 사전(dict.pid.user.txt) 로딩을 시도, 실패하면 메세지 출력후 진행
	+ [in] data_path: 리소스 디렉토리 경로 (예: ./data)
	+ [ret] 정상 초기화되었거나 이미 초기화 된 경우 0, 아닐 경우 1 반환
+ int pidRun(const char * p_text, PIDResult *p_result);
	+ 텍스트를 입력으로 받아, 출현한 개인정보 부분문자열의 정보를 반환
	+ [in] p_sent: 개인정보를 추출할 텍스트
	+ [out] p_result: 개인정보 문자열의 배열을 담을 구조체
		+ 구조체 정보 사용 후, 구조체 메모리 해제 함수를 불러줘야 함 (아래에서 설명)
	+ [ret] 개인정보 탐지 여부를 반환
		+ #define PID_FOUND_NONE 0 // 개인정보 검출 불가
		+ #define PID_FOUND_NORMAL 1 // 일반 개인정보 검출 성공
		+ #define PID_FOUND_RESIDENT_NO 2 // 주민번호 검출 성공
+ int pidRunLevel(const char * p_text, PIDResult *p_result, int detect_level);
	+ 검출할 정보의 수준을 조절하여 처리 (나머지는 pidRun()과 동일)
	+ [in] detect_level: 추출할 개인정보의 레벨
		+ 레벨이 높을수록 적게 탐지되면, 동시에 처리 시간이 줄어듬
		+ #define PID_DETECT_LEVEL_ALL 0 // 모든 대상 탐지 (기본값)
		+ #define PID_DETECT_LEVEL_PERSONAL_MISC 1 // 기타 개인 정보 (계좌번호, 주소, 차량등록번호, 카드번호, 이메일주소, 우편번호, 사업자 등록번호) 만 탐지
		+ #define PID_DETECT_LEVEL_CORE_SENSITIVE 2 // 중요 개인 식별 정보 + 민감 정보 (병명, 정치/사상 등) 만 탐지, (주소, 전화번호, 계좌번호 등은 탐지 안함)
		+ #define PID_DETECT_LEVEL_CORE 3 // 중요 개인 식별 정보 (주민번호, 외국인 등록번호, 여권번호, 운전면허번호) 만 탐지	
+ int pidRunType(const char *p_text, PidResult *p_result, int detect_type_bit);
	+ 검출할 타입을 bit로 지정하여 호출
		+ 미리 지정된 bit를 or로 조합하여 detect_type_bit 에 담아 전달
		+ 둘 이상의 type 정보를 or로 조합하여 호출 가능 (ex: PID_ADDRESS | PID_RESIDENT_NO)
		+ 필요한 타입만 검출할 경우, 처리 시간이 줄어듬
	+ 검출 타입 bit 목록 (include/pid.h 참고)
		+ #define PID_ACCOUNT		0x00000001 // 은행계좌번호
		+ #define PID_ADDRESS		0x00000002 // 주소
		+ #define PID_BIZ_NO		0x00000004 // 사업자등록번호
		+ #define PID_CAR_NO		0x00000008 // 자동차등록번호
		+ #define PID_CARD_NO		0x00000010 // 신용카드 번호
		+ #define PID_DRIVER_NO		0x00000020 // 운전면허번호
		+ #define PID_EMAIL		0x00000040 // 이메일 주소
		+ #define PID_HEALTH_INS_NO	0x00000080 // 건강보험증 번호
		+ #define PID_PASSPORT		0x00000100 // 여권번호
		+ #define PID_PHONE		0x00000200 // 전화번호
		+ #define PID_RESIDENT_NO	0x00000400 // 주민등록번호
		+ #define PID_ZIP_CODE		0x00000800 // 우편번호
		+ #define PID_KEYWORD		0x00001000 // 민감성 키워드
		+ #define PID_YYMMDD		0x00002000 // 주민번호앞자리

		+ #define PID_BIT_ALL		0xFFFFFFFF // 전체
		+ #define PID_BIT_CORE		(PID_RESIDENT_NO | PID_PASSPORT | PID_DRIVER_NO)
		+ #define PID_BIT_CORE_SENSITIVE (PID_BIT_CORE | PID_KEYWORD)
		+ #define PID_BIT_PERSONAL_MISC	(PID_ACCOUNT | PID_ADDRESS | PID_CAR_NO | PID_CARD_NO | PID_EMAIL | PID_PHONE | PID_ZIP_CODE | PID_BIZ_NO | PID_HEALTH_INS_NO)
+ int pidRunTypeEx(const char *p_text, const char *p_prev_text, PidResult *p_result, int detect_type_bit, int ex_detect_type_bit);
	+ detect_type과 ex_detect_type(확장 정보) 을 bit로 지정하여 검출하는 경우
	+ 현재 입력된 텍스트 외에 추가로 앞쪽 텍스트를 문맥으로 전달하여 판별하는 경우 (계좌번호, 카드번호, 이름 등)
	+ [in] p_prev_text: 추가로 검토할 앞쪽 텍스트 문맥 (이 텍스트에 "계좌", "은행", "카드", "성함", "성명" 등이 있으면 필요시 참조)
	+ [in] ex_detect_type_bit: 추가 검출할 ex_type의 bit or 정보
	+ EX_TYPE 검출 bit 목록 (include/pid.h 참고)
		+ #define PID_EX_KORNAME			0x00100000 // 한국 인명
		+ #define PID_EX_DISTRICT			0x00200000 // 행정구역명 (2개 이상 연속 출현시만 검출)
		+ #define PID_BIT_EX_ALL	(PID_EX_KORNAME | PID_EX_DISTRICT)
		
+ const char *pidGetTypeName(int type);
	+ 부분문자열 type 숫자를 받아서, 해당 숫자 타입의 문자열을 반환
	+ 패턴 이름은 pattern.pid.txt의 메인 패턴 문자열(첫번째 칼럼) 중, "_" 시작 전 부분
	+ 패턴명 목록
		+ ACCOUNT	계좌번호
		+ ADDRESS	주소
		+ CAR-NO	차량등록번호
		+ CARD-NO	카드번호
		+ DRIVER-NO	운전면허번호
		+ EMAIL		이메일주소
		+ KEYWORD	민감정보 사전에 등록된 어휘
		+ PASSPORT	여권번호
		+ PHONE		전화번호
		+ RESIDENT-NO	주민등록번호 (혹은 외국인 등록번호)
		+ ZIP-CODE	우편번호
		+ HEALTH-INS-NO	건강보험증 번호
		+ BIZ-NO	사업자 등록번호	
		+ YYMMDD	년월일 (주민번호 앞자리)
		+ KORNAME	한국인명
		+ DISTRICT	행정구역명 (2개 이상 연속 출현시만 검출)

+ void pidDeleteResult(PidResult *p_result);
	+ p_result->arr_part 배열의 메모리를 해제
	+ 구조체 정보 활용 후 꼭 이 함수를 호출하여 결과 버퍼를 릴리즈 해야 함
+ void pidClose();
	+ PID 종료 (리소스 반환)
+ void pidSetOption(int option):
	+ PID의 옵션을 설정
	+ 옵션 목록 (include/pid.h 참고)
		+ #define PID_OPTION_CHECK_DIGIT 0x0001 // 이어진 digit 에서 자릿수나 prefix 혹은 내부범위제약 (YYMMDD)을 지켰는지 체크. 그게 아닌 경우는 검출 대상에서 제외

## 구조체 설명
+ StrPart: 텍스트에서 개인정보가 출현한 부분문자열의 정보
	+ int begin;	// 시작 위치 (바이트)
	+ int len;	// 길이 (바이트)
	+ int begin_syll;	// 시작 위치 (음절)
	+ int len_syll;	// 길이 (음절)
	+ int type;	// 타입 (정수, pidGetTypeName() 을 통해 문자열로 변환 가능)
		+ 실제로는 패턴 번호의 정보임
		+ 따라서 동일한 패턴이라 하더라도 서로 다른 번호일 수 있음 (ADDRESS의 경우 여러 패턴으로 기술됨)
		+ 부분문자열의 타입을 활용할 때에는 문자열로 바꾸어서 사용하는 것이 좋음
+ PidResult: 개인정보 부분문자열(StrPart) 을 담고 있는 결과 구조체
	+ StrPart *arr_part;	// 문서 전체에서 찾은 부분문자열(StrPart)의 배열
	+ int cnt;		// 문서 전체에서 찾은 부분문자열(StrPart)의 개수

## 사용 예제
+ example/pid_run.c
```c++
/*
 * pid_run.c
 *
 *  Created on: 2021. 10. 27.
 *  Last Modified: 2022. 6. 14.
 *      Author: ywseong
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "pid.h" // PID C 인터페이스 선언

#define LEN_BUFF 1024000
int main(int argc, char **argv) {
	const char *p_data_path = "./data/"; // project root 에서 실행한다고 가정한 경우, 실행 경로나 데이터 폴더가 바뀌면 수정해 주어야 함.

	int b_ex = 0;
	int option = 0;
	char buff[LEN_BUFF];
	memset(buff, 0, LEN_BUFF);
	int i = 0;
	for (i = 1; i < argc; i++) {
		if (strcmp(argv[i], "--ex") == 0)
			b_ex = 1;
		else if (strcmp(argv[i], "--check_digit") == 0) {
			option = PID_OPTION_CHECK_DIGIT;
			pidSetOption(option);
		}
		else {
			if (strlen(buff) + strlen(argv[i]) + 1 >= LEN_BUFF)
				break;
			if (buff[0] != 0)
				strcat(buff, " ");
			strcat(buff, argv[i]);
		}
	}
	const char *p_text = buff;

	if (*p_text == 0) // 기본 테스트 문장 세팅
		p_text = "주민번호는 칠사공일일일 일이삼사오륙칠이고, 주소는 강동구 길동 삼익파크맨션 백구동 천오백일호야. 김철수 홍길동 740111 성동구 성수동 번호 742011 전번 01011111111 전번 11111111 전번 22 22 2222";	

	printf("[PID] INPUT : %s\n", p_text);
	PidResult rst = {0,0}; // 결과 구조체 초기화
	int found_type = 0;

	if (b_ex == 0) { // normal mode (ex_type (DISTRICT, KORNAME) 등은 검출하지 않는 경우)
		if (pidOpen(p_data_path) != 0) { // PID 사전 오픈, 여러 문장 호출시 open은 한번만 수행
			printf("[PID] Error in pidOpen(\"%s\")\n", p_data_path);
			return 1;
		}

		found_type = pidRun(p_text, &rst); // PID 실행 (모든 패턴 탐지, ex_type은 제외)
		// detect_level 을 지정하여 호출하는 경우라면 다음과 같이 실행
		// found_type = pidRunLevel(p_text, &rst, PID_DETECT_LEVEL_CORE); // 중요 개인 식별 정보 (주민번호, 외국인 등록번호, 여권번호, 운전면허번호) 만 탐지
		// found_type = pidRunLevel(p_text, &rst, PID_DETECT_LEVEL_CORE_SENSITVE); // 중요 개인 식별 정보 + 민감정보 (병명, 정치/사상 등) 탐지

		// detect_type을 지정하여 호출하는 경우라면 다음과 같이 실행
		// found_type = pidRunType(p_text, &rst, PID_RESIDENT_NO | PID_ADDRESS | PID_YYMMDD); // 주민번호(전체, 앞자리)와 주소만 탐지
	}
	else { // ex_type (DISTRICT, KORNAME)까지 지정하거나, 앞쪽 문맥을 지정하여 호출하는 경우라면 다음과 같이 실행
		if (pidOpenKorname(p_data_path) != 0) { // PID 사전 오픈 (korname detect mode, kma 도 함께 오픈함), 여러 문장 호출시 open은 한번만 수행
			printf("[PID] Error in pidOpenKorname(\"%s\")\n", p_data_path);
			return 1;
		}

		const char *p_prev_text = 0; // 앞 문장 등을 문맥 체크 대상으로 세팅할 경우 (카드, 은행, 계좌 등)
		found_type = pidRunTypeEx(p_text, p_prev_text, &rst, PID_BIT_ALL, PID_BIT_EX_ALL); // 일반 개인정보 및 ex_type 모두 탐지, 이름을 탐지해야 하므로, pidOpenKorname() 으로 초기화 필요
		//found_type = pidRunTypeEx(p_text, p_prev_text, &rst, PID_YYMMDD, PID_BIT_EX_ALL); // YYMMDD + ex_type 모두 탐지, 이름을 탐지해야 하므로, pidOpenKorname() 으로 초기화 필요
		// found_type = pidRunTypeEx(p_text, p_prev_text, &rst, PID_BIT_ALL, PID_EX_KORNAME); // 일반 개인정보 및 KORNAME 탐지, 이름을 탐지해야 하므로, pidOpenKorname() 으로 초기화 필요
		// found_type = pidRunTypeEx(p_text, p_prev_text, &rst, PID_BIT_ALL, PID_EX_DISTRICT); // 일반 개인정보 및 DISTRICT 탐지
	}

	if (found_type == PID_FOUND_NONE)
		printf("[PID] Found None\n");
	else {
		if (found_type == PID_FOUND_RESIDENT_NO)
			printf("[PID] Found Resident No\n");
		else
			printf("[PID] Found Normal\n");

		for (i = 0; i < rst.cnt; i++) {
			StrPart *p_part = &(rst.arr_part[i]);
			const char *pstr_type = pidGetTypeName(p_part->type);
			char *buff_rst = (char *)malloc(p_part->len+1);
			strncpy(buff_rst, p_text + p_part->begin, p_part->len);
			buff_rst[p_part->len] = 0;
			printf("\t[%s] %s\n", pstr_type, buff_rst);
			free(buff_rst);
		}
	}
	pidDeleteResult(&rst); // rst안의 StrPart 버퍼 메모리 해제
	pidClose(); // PID 종료
	return 0;
}

```


# PID 직접 빌드 설명
## BUILD ENVIRONMENT SETTING
+ 각 빌드 환경이 다른 경우, 시스템 환경변수가 적용될 수 있습니다.
+ 적용 대상 환경변수는 다음과 같습니다.
	+ CC : gcc
	+ CXX : g++
	+ JAVA_HOME : java home directory path
	+ PYTHON_HOME : python home directory path
+ 시스템 환경변수 미설정 시 기본값은 다음과 같습니다.
	+ CC : gcc
	+ CXX : g++
	+ JAVA_HOME
		+ macOS : $(shell /usr/libexec/java_home)
		+ linux : /usr/lib/jvm/java-1.8.0-openjdk
	+ PYTHON_HOME : /usr
+ Java & Python Wrapper Interface 빌드
    + swig 를 활용하여 Java 및 Python 라이브러리 빌드를 지원
    + swig/ 폴더에 리눅스 swig 실행 파일이 포함되어 있음
    + 필요시 install_swig.sh shell 파일을 실행하여, 특정 버전의 swig를 설치
    + 현재 사용 버전은 swig 2.0.12

## CMAKE BUILD TUTORIAL
+ 전체 빌드: pid root directory에서
```bash
$ mkdir build
$ cd build/
$ cmake ..
$ make [all] # 전체 C/C++ 라이브러리만 빌드 => lib/pid/

```
+ Java, Python 모듈 빌드
```bash
$ mkdir build
$ cd build/
$ cmake ..
$ make pidjava # 자바 라이브러리 빌드 => lib/java/
$ make pidpython # 파이썬 라이브러리 빌드 => lib/python/

```

## 필요 구성요소
+ root
	+ readme.md: 현재 파일
	+ release_note.txt: 릴리즈 노트
	+ CMakeLists.txt: root cmake 파일
	+ install_swig.sh: swig install script, java 및 python 라이브러리 빌드 시 미리 실행 필요
+ src/: PID의 소스 디렉토리
	+ pid.h: PID 모듈의 c 헤더 (외부 노출 인터페이스 선언)
	+ pid.hpp: PID 모듈의 c++헤더
	+ pid.cpp: PID 모듈 소스
	+ CMakeLists.txt: src cmake 파일
	+ pidpython.i: swig python interface 파일
	+ pidjava.i: swig java interface 파일
+ src/java/: swig java 예제 폴더
	+ example.java: java 라이브러리 사용 예제
	+ run_exam.sh: java 예제 파일 실행 스크립트
+ src/python/: swig python 예제 폴더
	+ example.py: python 라이브러리 사용 예제
+ data/: PID가 사용하는 리소스 디렉토리
	+ pattern.pid.bin: 개인정보 패턴 사전 (바이너리)
	+ dict.pid.bin: 개인정보 어휘 사전 (바이너리)
	+ dict.pid.user.txt: 개인정보 사용자 어휘 사전 (텍스트, 편집 가능)
		+ 형식: 스트링[탭]태그
		+ 태그:
			+ 1글자 알파벳
			+ 대문자: 공백 뒤에서만 허용
				+ B: Block Word (추출 방지)
				+ H: House (주거용 건물명)
				+ T: Town (동네이름, 면동리, 도로명)
				+ N: Name (한국인명, 기본 상태에서 검출되지 않는 인명이 있을시, 여기 등록하여 처리, 예: "배고파[탭]N" => "배고파"가 이름으로 뽑히게 됨)
				+ E: Entity (기타 개체명, 기본 상태에서 검출되는 이름 중, 제외할 것이 있으면, 여기 등록하여 처리, 예: "홍길동[탭]E" => "홍길동"이 이름으로 안 뽑히게 됨)
			+ 소문자: 어절 가운데에서도 허용
				+ s: sensitive word (민감정보 어휘)
				+ h: house (주거용 건물명 헤드, 아파트, 맨션, 롯데캐슬 등)
				+ b: business (상업용 건물명 헤드, 주차장, 공원, 경기장 등)
+ data/data_kma/: kma가 사용하는 리소스 디렉토리 (인명 검출시 내부적으로 kma를 구동함)
+ data_dev/: PID가 사용하는 개발용 리소스 디렉토리
	+ pattern.pid.txt: 개인정보 패턴 사전 (텍스트)
		+ 형식: 패턴이름[탭]패턴내용
		+ 패턴내용은 정규식 + 서브패턴명 으로 구성됨
		+ 서브패턴:
			+ 탭으로 시작, 다른 서브패턴을 활용할 수 있음
			+ 서브패턴은 모듈 로딩시 최종 정규식으로 확장됨
	+ dict.pid.txt: 개인 정보 어휘 사전 (텍스트)
		+ 형식: 스트링[탭]태그
		+ 태그:
			+ 1글자 알파벳
			+ 대문자: 공백 뒤에서만 허용
				+ B: Block Word (추출 방지)
				+ H: House (주거용 건물명)
				+ T: Town (동네이름, 면동리, 도로명)
			+ 소문자: 어절 가운데에서도 허용
				+ s: sensitive word (민감정보 어휘)
				+ h: house (주거용 건물명 헤드, 아파트, 맨션, 롯데캐슬 등)
				+ b: business (상업용 건물명 헤드, 주차장, 공원, 경기장 등)
+ example/: PID 라이브러리 사용 예제
	+ pid_run.c: 라이브러리 사용 예제 코드
+ include/: 모듈 인터페이스가 정의된 헤더가 위치
+ lib/: 빌드된 라이브러리가 저장되는 폴더
+ lib/pid/: c 라이브러리 저장 폴더
+ lib/java/: java 라이브러리 저장 폴더
+ lib/python/:python 라이브러리 저장 폴더
+ lib/pcre/: pcre 라이브러리가 저장되어 있는 폴더 (빌드시 참조)
+ lib/kma/: kma 라이브러리가 저장되어 있는 폴더 (빌드시 참조)
+ bin/: 빌드된 실행 파일이 저장되는 폴더 (bin/pid)
+ swig/: swig 실행 파일이 저장된 폴더



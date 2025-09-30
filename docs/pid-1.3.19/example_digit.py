#!/usr/bin/python
# -*- coding:utf-8 -*-

import os
import sys

from pidpy.pidpython import *
from klpy import *
import pidpy

def print_pid_result(text, list_str_part):
	for str_part in list_str_part:
		s = text[str_part.begin_syll:str_part.begin_syll + str_part.len_syll]
		type_name = PID.GetTypeSimpleName(str_part.type)
		print("[" + type_name + "] " + s);
	
def main():
	data_path = os.path.dirname(pidpy.__file__)
	b_read_user_dict = False # 사용자 사전을 사용할 경우, True로 변환하여 호출
	b_read_name_dict = False; # korname 을 분석할 때, name dictionary 및 kma를 활용하므로, 이를 Init()에 전달
	b_open_ptnchunker = False # ptnchunker 로 중의성을 해소하는 경우, strict mode로 사용할 때는 False로 사용해도 결과가 유사
	if PID.Init(data_path, b_read_user_dict, b_read_name_dict, b_open_ptnchunker) == False:
		print("PID has init error", file=sys.stderr)
		PID.Terminate()
		return

	# 숫자열 체크가 불필요한 경우는 아래 두 라인 삭제 (아래 예제 문장에서는 12341234 의 phone 출력 여부가 바뀜)
	option = PID_OPTION_CHECK_DIGIT
	PID.SetOption(option)
	
	text = "주민번호는 칠사공일일일 일이삼사오륙칠이고, 주소는 강동구 길동 삼익파크맨션 백구동 천오백일호야 김철수 홍길동 740111 성동구 성수동, 전화 번호는 공 일 공 에 일 이 삼 사 에 일 이 삼 사 번이야 공 일 공 네 그리고요 일 이 삼 사 에 네 일 이 삼 사"
	list_str_part_ex = StrPartVector()
	prev_text = "" # 앞 문장을 문맥으로 넘기는 경우 이 변수로 전달

	# 검출할 타입 지정 (상수 정의는 include/pid.h 참조)
	detect_type_bit = PID_BIT_CORE | PID_BIT_PERSONAL_MISC
	ex_detect_type_bit = PID_EX_KORDIGIT | PID_EX_LONGDIGIT

	# PID 호출
	rc = PID.RunTypeEx(text, prev_text, list_str_part_ex, detect_type_bit, ex_detect_type_bit)

	# 결과 출력
	print_pid_result(text, list_str_part_ex)


	PID.Terminate()


if __name__=='__main__':
	main()





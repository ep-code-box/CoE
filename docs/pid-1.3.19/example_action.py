#!/usr/bin/python
# -*- coding:utf-8 -*-

import os
import sys

from pidpy.pidpython import *
import pidpy

def print_pid_result(text, list_str_part):
	for str_part in list_str_part:
		s = text[str_part.begin_syll:str_part.begin_syll + str_part.len_syll]
		type_name = PID.GetTypeSimpleName(str_part.type)
		print("[" + type_name + "] " + s);
	
def main():
	pid_mode = PID_MODE_ACTION # action mode 설정

	# 초기화
	#data_path = "../../data"
	data_path = os.path.dirname(pidpy.__file__)
	
	if PID.InitMode(data_path, pid_mode) == False:
		print("PID has init error", file=sys.stderr)
		PID.Terminate()
		return

	# 숫자열 체크 정확성 강화 설정
	option = PID_OPTION_CHECK_DIGIT
	PID.SetOption(option)
	
	# action mode 의 추천 option값
	detect_type_bit = PID_BIT_ACTION
	ex_detect_type_bit = 0
	b_consider_all_types = False

	# run pid
	text = "우리 회사는 센트로폴리스 27층이고요 계좌번호는 농협은행 663-67-8878-768 이야"

	list_str_part = StrPartVector()
	prev_text = "" # 앞 문장을 문맥으로 넘기는 경우 이 변수로 전달
	rc = PID.RunTypeEx(text, prev_text, list_str_part, detect_type_bit, ex_detect_type_bit, b_consider_all_types)
	
	# print result
	print_pid_result(text, list_str_part)

	# terminate
	PID.Terminate()


if __name__=='__main__':
	main()





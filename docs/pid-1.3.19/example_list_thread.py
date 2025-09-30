#!/usr/bin/python
# -*- coding:utf-8 -*-

import os
import sys

from pidpy.pidpython import *
from klpy import *
import pidpy

def print_pid_line_result(lines, list_line_str_part):
	for line_str_part in list_line_str_part:
		line = lines[line_str_part.n_line];
		s = line[line_str_part.begin_syll : line_str_part.begin_syll + line_str_part.len_syll]
		type_name = PID.GetTypeSimpleName(line_str_part.type)
		print(str(line_str_part.n_line) + " [" + type_name + "] " + s);
	
def main():
	data_path = os.path.dirname(pidpy.__file__)
	
	b_read_user_dict = False # 사용자 사전을 사용할 경우, True로 변환하여 호출
	b_read_name_dict = True # korname 을 분석할 때, name dictionary 및 kma를 활용하므로, 이를 Init()에 전달
	b_open_ptnchunker = False # ptnchunker 로 중의성을 해소하는 경우, strict mode로 사용할 때는 False로 사용해도 결과가 유사
	if PID.Init(data_path, b_read_user_dict, b_read_name_dict, b_open_ptnchunker) == False:
		print("PID has init error", file=sys.stderr)
		PID.Terminate()
		return

	# 숫자열 체크가 강화 옵션
	option = PID_OPTION_CHECK_DIGIT
	PID.SetOption(option)

	"""
	detect_type_bit = 0
	ex_detect_type_bit = 0
	b_consider_all_types = False
	PID.GetModeDetectBit(mode, detect_type_bit, ex_detect_type_bit, b_consider_all_types)
	"""
	detect_type_bit = PID_BIT_CORE | PID_BIT_PERSONAL_MISC
	ex_detect_type_bit = PID_EX_KORNAME
	list_org_text = ["주민번호는 740111 1234567이고", 
		"주소는 강동구 길동 삼익파크맨션 109동 1501호야",
		"김철수 홍길동 740111 성동구 성수동", 
		"전화 번호는 010에 1234에 1234번이야",
		"010 네 그리고요 1234에 네 1234",
		"abc@naver.com",
		"def main()",
		"for (int i = 0; i < 100; i++)",
		"void ParseText() // 김철수",
		"bool b_ok = ParseText('김철수')",
		"//////// comment //////////////////"]


	list_text = StrVector()
	
	for x in range(100):
		for y in range(len(list_org_text)):
			list_text.append(list_org_text[y])
			
	#Multi-Thread options
	list_check_str = StrVector()
	list_check_str.append("@")
	b_check_kor = True
	b_check_alpha = False
	b_check_digit = True
	b_verbose = True	
	cnt_thread = 8

	# PID Multi-thread Line List 호출
	list_line_str_part = PID.RunMultiThreadStr(list_text, list_check_str, b_check_kor, b_check_alpha, b_check_digit, detect_type_bit, ex_detect_type_bit, cnt_thread, b_verbose)

	# 결과 출력
	print_pid_line_result(list_text, list_line_str_part)


	PID.Terminate()


if __name__=='__main__':
	main()





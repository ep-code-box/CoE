#!/usr/bin/python
# -*- coding:utf-8 -*-

import os
import sys

from pidpy.pidpython import *
from klpy import *
import pidpy

# PID의 상수 정의는 include/pid.h 를 참고

def print_pid_result(text, list_str_part):
	for str_part in list_str_part:
		s = text[str_part.begin_syll:str_part.begin_syll + str_part.len_syll]
		type_name = PID.GetTypeSimpleName(str_part.type)
		print("[" + type_name + "] " + s);
	
def main():
	# ex_mode 설정, ex_mode에서는 처리 시간과 메모리가 더 소요되므로, 필요한 경우에만 사용
	b_ex_mode = False  # KORNAME, DISTRICT 등 ex 기능을 사용하지 않는 경우에는 이를 False 로 변경하여 아래 코드를 수행
	b_strict_mode = False # 1.3.8 에서 신설된 STRICT mode 로 사용하는 경우

	#data_path = "../../data"
	data_path = os.path.dirname(pidpy.__file__)

	b_read_user_dict = False # 사용자 사전을 사용할 경우, True로 변환하여 호출
	b_read_name_dict = b_ex_mode; # korname 을 분석할 때, name dictionary 및 kma를 활용하므로, 이를 Init()에 전달
	b_open_ptnchunker = False # ptnchunker 로 중의성을 해소하는 경우, strict mode로 사용할 때는 False로 사용해도 결과가 유사
	if PID.Init(data_path, b_read_user_dict, b_read_name_dict, b_open_ptnchunker, b_strict_mode) == False:
		print("PID has init error", file=sys.stderr)
		PID.Terminate()
		return

	# 숫자열 체크가 불필요한 경우는 아래 두 라인 삭제 (아래 예제 문장에서는 12341234 의 phone 출력 여부가 바뀜)
	option = PID_OPTION_CHECK_DIGIT
	PID.SetOption(option)
	
	text = "주민번호는 칠사공일일일 일이삼사오륙칠이고, 주소는 강동구 길동 삼익파크맨션 백구동 천오백일호야. 김철수 홍길동 740111 성동구 성수동, 번호는 12341234"
	list_str_part = StrPartVector()
	rc = PID.Run(text, list_str_part) # default mode : detect all level
	print_pid_result(text, list_str_part)

	list_str_part2 = StrPartVector()
	rc = PID.Run(text, list_str_part2, 2) # detect_level 지정 : 1 : 개인식별정보 + 민감정보, 2 : 민감정보만 출력
	print_pid_result(text, list_str_part2)

	list_str_part3 = StrPartVector()
	rc = PID.RunType(text, list_str_part3, PID_ADDRESS) # detect_type 지정
	print_pid_result(text, list_str_part3)

	list_str_part4 = StrPartVector()
	rc = PID.RunType(text, list_str_part4, PID_ADDRESS | PID_RESIDENT_NO) # detect_type 지정
	print_pid_result(text, list_str_part4)

	if b_ex_mode:
		print("EX")
		list_str_part_ex = StrPartVector()
		prev_text = "" # 앞 문장을 문맥으로 넘기는 경우 이 변수로 전달
		rc = PID.RunTypeEx(text, prev_text, list_str_part_ex, PID_BIT_ALL, PID_BIT_EX_ALL) # basic type 전체, ex type 전체 출력
		print_pid_result(text, list_str_part_ex)

	b_sentresult = True # & sentresult 입력 테스트 (1.3.8)
	if b_sentresult:
		kma_option = KMA_SPLIT_NOUN
		print("open_kma()!")
		open_kma(option=kma_option)
		sent_result = SentResult()
		cnt_morphs = run_kma(sent_result=sent_result, text=text, option=kma_option)
		if cnt_morphs:
			prev_text = ""
			list_str_part_ex = StrPartVector()
			rc = PID.RunTypeExSentResult(text, prev_text, sent_result, list_str_part_ex, PID_BIT_ALL, 0);			
			print_pid_result(text, list_str_part_ex)
			replaced = PID.ReplaceStrPart(text, "[%t:%m*:%f]", list_str_part_ex)
			print("replaced([type:mask:fake]): " + replaced)
		close_sent_result(sent_result)
		close_kma()
	PID.Terminate()


if __name__=='__main__':
	main()





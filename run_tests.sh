#!/bin/bash
g++ -std=c++11 -DNDEBUG -Wall *.cpp -o wc.out

TESTS_TO_RUN=600

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

shopt -s nullglob
FAILED_TESTS=0
#dos2unix -q fileTests/inFiles/*
#dos2unix -q fileTests/outFiles/*

for i in fileTests/inFiles/test*.in
do
	if [[ ${i//[^0-9]/} -gt $TESTS_TO_RUN ]]; then
		continue
	fi

	printf "test $i >>>  "
#	./FileTester $i fileTests/inFiles/test${i//[^0-9]/}.in fileTests/outFiles/test${i//[^0-9]/}.result
	./wc.out < $i > fileTests/outFiles/test${i//[^0-9]/}.result
	diff fileTests/outFiles/test${i//[^0-9]/}.out fileTests/outFiles/test${i//[^0-9]/}.result

	if [ $? -eq 0 ]
	then
		printf "World Cup Simulation: ${GREEN}pass${NC},   "
	else
		printf "World Cup Simulation: ${RED}fail${NC},   "
		FAILED_TESTS+=1
	fi
#	valgrind --log-file=$i.valgrind_log --leak-check=full ./FileTester $i fileTests/inFiles/test${i//[^0-9]/}.in fileTests/outFiles/test${i//[^0-9]/}.vresult 1>/dev/null 2>/dev/null
  valgrind --log-file=$i.valgrind_log --leak-check=full ./wc.out < $i  1>fileTests/outFiles/test${i//[^0-9]/}.vresult 2>/dev/null

	rm  fileTests/outFiles/test${i//[^0-9]/}.vresult
	if [ -f $i.valgrind_log ]
	then
		cat $i.valgrind_log | grep "ERROR SUMMARY: 0" > /dev/null
		if [ $? -eq 0 ]
		then
			printf "Leak: ${GREEN}pass${NC}\n"
		else
			printf "Leak: ${RED}fail${NC}\n"
			cat $i.valgrind_log
			FAILED_TESTS+=1
		fi
	else
		printf "Leak: ${RED}couldn't get valgrind file${NC}\n"
		FAILED_TESTS+=1
	fi
	rm $i.valgrind_log
done

if [ ${FAILED_TESTS} -eq 0 ]; then
	printf "\n${GREEN} All tests passed :)${NC}\n\n"
else
	printf "\n${RED} Failed ${FAILED_TESTS}${NC} tests.\n\n"
fi


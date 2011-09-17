# Makefile for pure c++ basic test

QL_INCLUDES=/opt/local/include
QL_LIBRARY=/opt/local/lib

FLAGS= -m32

build:
	g++ -Wall -fexceptions  -O2 -g -I. -I/usr/local/lib/QuantLib-1.0.1/ql -I/usr/local/QuantLib-1.0.1 -DHAVE_CONFIG_H -c EquityOption.cpp -o ./EquityOption.o
	g++  -o ./EquityOption ./EquityOption.o /usr/local/lib/libQuantLib.so

test:
	./EquityOption


build_issue:
	g++ -Wall -fexceptions  ${FLAGS} -O2 -g -I. -I$(QL_INCLUDES) -DHAVE_CONFIG_H -c bond_issue.cpp ql_settings.cpp 
	g++ ${FLAGS} -o ./bond_issue ./bond_issue.o ./ql_settings.o -L${QL_LIBRARY} -lQuantLib

test_issue:
	./bond_issue
	

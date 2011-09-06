# Makefile for pure c++ basic test

build:
	g++ -Wall -fexceptions  -O2 -g -I. -I/usr/local/lib/QuantLib-1.0.1/ql -I/usr/local/QuantLib-1.0.1 -DHAVE_CONFIG_H -c EquityOption.cpp -o ./EquityOption.o
	g++  -o ./EquityOption ./EquityOption.o /usr/local/lib/libQuantLib.so

test:
	./EquityOption
	

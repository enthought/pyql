# Makefile for pure c++ basic test

# darwin
# QL_INCLUDES=/opt/local/include
# QL_LIBRARY=/opt/local/lib

# linux2 (1.1)
QL_INCLUDES=/opt/QuantLib-1.1
QL_LIBRARY=/opt/QuantLib-1.1/ql/.libs

FLAGS= -m32

clean:
	rm *.o

.cpp.o:
	g++ -Wall -fexceptions  -O2 -g -I. -I${QL_INCLUDES} -DHAVE_CONFIG_H -c -o $@ -c $<
	
EquityOption: EquityOption.o
	g++  ${FLAGS} -o $@ $^ -L${QL_LIBRARY} -lQuantLib

test_equity:
	./EquityOption


bond_issue: bond_issue.o ql_settings.o
	g++  ${FLAGS} -o $@ $^ -L${QL_LIBRARY} -lQuantLib

test_issue:
	./bond_issue

hestonmodel: hestonmodel.o utilities.o
	g++  ${FLAGS} -o $@ $^ -L${QL_LIBRARY} -lQuantLib

test_heston:
	./hestonmodel

batesprocess: batesprocess.o utilities.o
	g++  -o $@ $^ -L${QL_LIBRARY} -lQuantLib

test_bates: build_bates
	./batesprocess


build:
	python setup.py build_ext --inplace

build3:
	python3 setup.py build_ext --inplace

docs:
	make -C docs html

install:
	pip install .

uninstall:
	pip uninstall quantlib

tests-preload:
	LD_PRELOAD=/opt/QuantLib-1.1/lib/libQuantLib.so nosetests -v quantlib/test

tests:
	cd quantlib/test
	python -m unittest discover -v

tests3:
	cd quantlib/test
	python3 -m unittest discover -v

build_ex:
	g++ -m32 -I/opt/local/include/ -I/opt/local/include/boost quantlib_test2.cpp \
    -o test2 -L/opt/local/lib/ -lQuantLib

clean:
	find quantlib -name \*.so -exec rm {} \;
	find quantlib -name \*.pyc -exec rm {} \;
	find quantlib -name \*.cpp -exec rm {} \;
	find quantlib -name \*.c -exec rm {} \;
	rm -rf build
	rm -rf dist

.PHONY: build docs clean

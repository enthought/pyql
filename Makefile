build:
	python setup.py build_ext --inplace

build2:
	python2 setup.py build_ext --inplace

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

tests2: build2
	cd quantlib/test
	python2 -m unittest discover -v

build_ex:
	g++ -m32 -I/opt/local/include/ -I/opt/local/include/boost quantlib_test2.cpp \
    -o test2 -L/opt/local/lib/ -lQuantLib

clean:
	find quantlib -name \*.so -exec rm {} +
	find quantlib -name \*.pyc -exec rm {} +
	find quantlib -name \*.cpp -exec rm {} +
	find quantlib -name \*.c -exec rm {} +
	find quantlib -name \*.h -exec rm {} +
	-rm quantlib/termstructures/yields/piecewise_yield_curve.pxd
	-rm quantlib/termstructures/yields/piecewise_yield_curve.pyx
	rm -rf build
	rm -rf dist

.PHONY: build build2 docs clean

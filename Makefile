
clean:
	find quantlib -name \*.so -exec rm {} \;
	find quantlib -name \*.pyc -exec rm {} \;
	find quantlib -name \*.cpp -exec rm {} \;
	find quantlib -name \*.c -exec rm {} \;
	rm -rf build
	rm -rf dist
docs:
	make -C docs html


build:
	python setup.py build_ext --inplace

install:
	python setup.py install --record pyql_install.txt

uninstall:
	cat pyql_install.txt | grep quantlib | xargs rm -rf

tests-preload:
	LD_PRELOAD=/opt/QuantLib-1.1/lib/libQuantLib.so nosetests -v quantlib/test
tests:
	#nosetests -v quantlib/test
	cd quantlib/test
	python -m unittest discover -v

build_ex:
	g++ -m32 -I/opt/local/include/ -I/opt/local/include/boost quantlib_test2.cpp \
    -o test2 -L/opt/local/lib/ -lQuantLib

.PHONY: build  docs

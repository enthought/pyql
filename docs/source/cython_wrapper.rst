How to wrap QuantLib classes with cython
========================================

These notes provide a step by step guide to wrapping a QuantLib (QL) class
with cython, so that it can be invoked from python. 

The objective is to make available in python a set of modules that exactly mirror 
the QL class hierarchy. For example, QL provides a class 
named ''SimpleQuote'', that represents a simple price measurement. 
The C++ class is defined as follows::

    class SimpleQuote : public Quote {
      public:
        SimpleQuote(Real value = Null<Real>());
        Real value() const;
        bool isValid() const;
        Real setValue(Real value = Null<Real>());
    };

After wrapping the C++ class, this class is now available in python:

   from quantlib.quotes import SimpleQuote
   spot = SimpleQuote(3.14)
   print('Spot %f' % spot.value)

A couple of observations are worth mentioning:

* pyql preserves the module hierarchy of QuantLib: 
the SimpleQuote class is defined in the quote module in C++.

* pyql exposes QuantLib in a pythonic fashion: instead of exposing the accessor value(),
 pyql implements the property value. 

The Interface Code
------------------

To expose QL class ''foo'', you need to create three files. For the sake of
standardization, they should be named as follows:

:_foo.pxd: A header file to declare the C++ class being exposed,
:foo.pxd: A header file where the corresponding python class is declared
:foo.pyx: The implementation of the corresponding python class

The content of each file is now described in details.

Declaration of the QL classes to be exposed
-------------------------------------------

This file contains the declaration of the 
QL class being exposed. For example, the header file ''_quotes.pxd''
is as follows:: 

    # distutils: language = c++
    # distutils: libraries = QuantLib

    include 'types.pxi'

    from libcpp cimport bool

    cdef extern from 'ql/quote.hpp' namespace 'QuantLib':
	cdef cppclass Quote:
	    Quote() except +
	    Real value() except +
	    bool isValid() except +

    cdef extern from 'ql/quotes/simplequote.hpp' namespace 'QuantLib':

	cdef cppclass SimpleQuote(Quote):
	    SimpleQuote(Real value) except +
	    Real setValue(Real value) except +
 
In this file, we declare the class ''SimpleQuote'' and its parent ''Quote''.
The syntax is almost identical to the corresponding c++ header file. The 
types used in declaring arguments are defined in ''types.pxi''.

The clause 'except +' signals that the method may throw an exception. It
is indispensible to append this clause to every declaration. Without it, an
exception thrown in QL will terminate the python process.

Declaration of the python class
-------------------------------

The second header file declares the python classes that will be wrapping 
the QL classes. The file ''quotes.pxd'' is reproduced below::

    cimport _quote as _qt
    from quantlib.handle cimport shared_ptr

    cdef class Quote:
        cdef shared_ptr[_qt.Quote]* _thisptr

Notice that in our header files we use 'Quote' to refer the the C++ class (in file _quote.pxd)
 and to the python class (in file quote.pxd). To avoid 
confusion we use the following convention:

 * the C++ class is always refered to as ''_qt.Quote''. 
 * the python class is always referd to as ''Quote''

The cython wrapper class holds a reference to the QL c++ class. As we do not
want to do any memory handling on the Python side, we always wrap the C++
object into a boost shared pointer that is deallocated properly when
deallocation the Cython extension.

Implementation of the python class
----------------------------------

The third file contains the implementation of the cython wrapper class. As an illustration, the implementation of the ''SingleQuote'' python class 
is reproduced below::

    cdef class SimpleQuote(Quote):

	def __init__(self, float value=0.0):
	    self._thisptr = new shared_ptr[_qt.Quote](new _qt.SimpleQuote(value))

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr # properly deallocates the shared_ptr and
                              # probably the target object if not referenced 

	def __str__(self):
	    return 'Simple Quote: %f' % self._thisptr.get().value()

	property value:
	    def __get__(self):
            if self._thisptr.get().isValid():
                return self._thisptr.get().value()
            else:
                return None

	    def __set__(self, float value):
            (<_qt.SimpleQuote*>self._thisptr.get()).setValue(value)

The ''__init__'' method invokes the c++ constructor, which returns a boost shared pointer.

Properties are used to give a more pythonic flavor to the wrapping. 
In python, we get the value of the ''SimpleQuote'' with the syntax
''spot.value'' rather than ''spot.value()'', had we exposed 
directly the C++ accessor.
    
Remember from the previous section that ''_thisptr'' is a shared pointer 
on a ''Quote'', which is a virtual class. The ''setValue'' 
method is defined in the ''SimpleQuote'' concrete class, 
and the shared pointer must therefore be cast 
into a ''SimpleQuote'' shared pointer in order to invoke ''setValue()''.
    
Managing C++ references using shared_ptr
----------------------------------------

All the Cython extension references should be declared using shared_ptr. The
__dealloc__ method should always delete the shared_ptr but never the target
pointer!

Every time a shared_ptr reference is received, never assigns the target pointer
to a local pointer variables as it might be deallocated. Always use the copy
constructor of the shared_ptr to get a local copy of it, stack allocated (there
is no need to use new)



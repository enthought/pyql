"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr
cimport _array as _arr

cdef extern from "array_support_code.hpp" namespace 'PyQL':
    void set_item(_arr.Array& a, Size key, double value) except +
cdef class Array:
    """
    1D array fore linear algebra
    """

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __init__(self):
        self._thisptr = NULL
        
    def __init__(self, size_t n, double value):
        self._thisptr = new shared_ptr[_arr.Array](new _arr.Array(n, value))
        
    def __init__(self, Size size, Real value):
        self._thisptr = new shared_ptr[_arr.Array](new _arr.Array(size, value))

    def __getitem__(self, Size i):
        return self._thisptr.get().at(i)

    def __setitem__(self, Size key, double value):
        if key >= self.size:
            raise ValueError('key larger than size of Array')
        cdef _arr.Array* array_ref = <_arr.Array*>self._thisptr.get()
        set_item(
            deref(array_ref), key, value)

    property size:
        def __get__(self):
            return self._thisptr.get().size()

cpdef qlarray_from_pyarray(p):
    x = Array(len(p), 0)
    for i in range(len(p)):
        x[i] = p[i]
    return x

cpdef pyarray_from_qlarray(a):
    return [a[i] for i in range(a.size)]

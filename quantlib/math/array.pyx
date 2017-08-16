"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

cimport _array as _arr


cdef class Array:
    """
    1D array for linear algebra
    """

    def __init__(self, Size size, value=None):
        if value is None:
            self._thisptr = _arr.Array(size)
        else:
            self._thisptr = _arr.Array(size, <Real?>value)

    def __getitem__(self, Size i):
        return self._thisptr.at(i)

    def __setitem__(self, Size key, Real value):
        if key < self._thisptr.size():
            self._thisptr[key] = value
        else:
            raise IndexError("index {} is larger than the size of the array {}".
                               format(key, self._thisptr.size()))

    property size:
        def __get__(self):
            return self._thisptr.size()

cpdef qlarray_from_pyarray(p):
    cdef Array x = Array(len(p))
    for i in range(len(p)):
        x._thisptr[i] = p[i]
    return x

cpdef pyarray_from_qlarray(a):
    return [a[i] for i in range(a.size)]

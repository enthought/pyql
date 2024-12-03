"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from quantlib.types cimport Real, Size
from cpython.ref cimport Py_INCREF
from libcpp.utility cimport move
cimport numpy as np

np.import_array()

cdef class Array:
    """
    1D array for linear algebra
    """

    def __init__(self, Size size=0, value=None):
        if value is None:
            self._thisptr = move[_arr.Array](_arr.Array(size))
        else:
            self._thisptr = move[_arr.Array](_arr.Array(size, <Real?>value))

    def __getitem__(self, Size i):
        return self._thisptr.at(i)

    def __setitem__(self, Size key, Real value):
        if key < self._thisptr.size():
            self._thisptr[key] = value
        else:
            raise IndexError("index {} is larger than the size of the array {}".
                               format(key, self._thisptr.size()))

    def __len__(self):
        return self._thisptr.size()

    def to_ndarray(self):
        cdef np.npy_intp[1] dims
        dims[0] = self._thisptr.size()
        cdef arr = np.PyArray_SimpleNewFromData(1, &dims[0], np.NPY_DOUBLE, <void*>(self._thisptr.begin()))
        Py_INCREF(self)
        np.PyArray_SetBaseObject(arr, self)
        return arr

cpdef qlarray_from_pyarray(p):
    cdef Array x = Array(len(p))
    for i in range(len(p)):
        x._thisptr[i] = p[i]
    return x

cpdef pyarray_from_qlarray(a):
    return [a[i] for i in range(a.size)]

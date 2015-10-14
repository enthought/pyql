"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

cimport _model as _mo
from quantlib.handle cimport shared_ptr
from cython.operator cimport dereference as deref
from quantlib.math.array cimport Array

cdef class CalibratedModel:

    def __cinit__(self):
        pass

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    def __init__(self):
        raise ValueError('Cannot instantiate a CalibratedModel')

    def params(self):
        # return self._thisptr.get().params()
        x = Array(3, 0)
        return x
    
    def set_params(self, Array params):
        self._thisptr.get().setParams(deref(params._thisptr.get()))

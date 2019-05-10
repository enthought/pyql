"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from quantlib.handle cimport shared_ptr
from cython.operator cimport dereference as deref
from quantlib.math.array cimport Array
cimport quantlib.math._array as _arr

cdef class CalibratedModel:

    def __init__(self):
        raise ValueError('Cannot instantiate a CalibratedModel')

    def params(self):
        cdef Array instance =  Array.__new__(Array)
        instance._thisptr = self._thisptr.get().params()
        return instance

    def set_params(self, Array params):
        self._thisptr.get().setParams(params._thisptr)

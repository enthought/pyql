"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport Handle, shared_ptr
from quantlib.util.compat cimport utf8_array_from_py_string

from libcpp cimport bool
from libcpp.string cimport string

from quantlib.index cimport Index
from quantlib.time.date cimport Period
from quantlib.time._period cimport Frequency
from quantlib.indexes.region cimport Region

from quantlib.currency.currency cimport Currency

cimport quantlib._index as _in
cimport quantlib.indexes._inflation_index as _ii

cdef class InflationIndex(Index):

    def __cinit__(self):
        pass

    property family_name:
        def __get__(self):
            cdef _ii.InflationIndex* ref = <_ii.InflationIndex*>self._thisptr.get()
            return ref.familyName()



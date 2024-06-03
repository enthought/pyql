"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from quantlib.handle cimport Handle, shared_ptr

from cython.operator cimport dereference as deref
from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from . cimport _euribor as _eu
cimport quantlib._index as _in
from quantlib.time.date cimport Period


cdef class Euribor(IborIndex):
    def __init__(self, Period tenor not None, HandleYieldTermStructure ts=HandleYieldTermStructure()):

        self._thisptr = shared_ptr[_in.Index](
            new _eu.Euribor(
                deref(tenor._thisptr), ts.handle
            )
        )

cdef class Euribor3M(Euribor):
    def __init__(self, HandleYieldTermStructure ts=HandleYieldTermStructure()):

        self._thisptr = shared_ptr[_in.Index](
            new _eu.Euribor3M(ts.handle)
        )

cdef class Euribor6M(Euribor):
    def __init__(self, HandleYieldTermStructure ts=HandleYieldTermStructure()):

        self._thisptr = shared_ptr[_in.Index](
            new _eu.Euribor6M(ts.handle)
        )

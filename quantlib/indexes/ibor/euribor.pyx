"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from cython.operator cimport dereference as deref
from quantlib.handle cimport HandleYieldTermStructure
from . cimport _euribor as _eu
from quantlib.time.date cimport Period


cdef class Euribor(IborIndex):
    def __init__(self, Period tenor not None, HandleYieldTermStructure ts=HandleYieldTermStructure()):

        self._thisptr.reset(
            new _eu.Euribor(
                deref(tenor._thisptr), ts.handle()
            )
        )

cdef class Euribor3M(Euribor):
    def __init__(self, HandleYieldTermStructure ts=HandleYieldTermStructure()):

        self._thisptr.reset(
            new _eu.Euribor3M(ts.handle())
        )

cdef class Euribor6M(Euribor):
    def __init__(self, HandleYieldTermStructure ts=HandleYieldTermStructure()):

        self._thisptr.reset(
            new _eu.Euribor6M(ts.handle())
        )

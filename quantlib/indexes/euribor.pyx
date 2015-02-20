"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from quantlib.handle cimport Handle, shared_ptr

from cython.operator cimport dereference as deref
from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure
cimport quantlib.termstructures._yield_term_structure as _yts
cimport _euribor as _eu
cimport quantlib._index as _in
from quantlib.time.date cimport Period


cdef class Euribor(IborIndex):
    def __init__(self,
        Period tenor,
        YieldTermStructure ts):

        cdef Handle[_yts.YieldTermStructure] ts_handle
        if ts.relinkable:
            ts_handle = Handle[_yts.YieldTermStructure](
                ts._relinkable_ptr.get().currentLink()
            )
        else:
            ts_handle = Handle[_yts.YieldTermStructure](
                ts._thisptr.get()
            )

        self._thisptr = new shared_ptr[_in.Index](
        new _eu.Euribor(
            deref(tenor._thisptr.get()),
            ts_handle)
        )

cdef class Euribor6M(Euribor):
    def __init__(self, YieldTermStructure ts=None):

        cdef Handle[_yts.YieldTermStructure] ts_handle
        if ts is None:
            self._thisptr = new shared_ptr[_in.Index](new _eu.Euribor6M())
        else:
            if ts.relinkable:
                ts_handle = Handle[_yts.YieldTermStructure](
                    ts._relinkable_ptr.get() #.currentLink()
                )
            else:
                ts_handle = Handle[_yts.YieldTermStructure](
                    ts._thisptr.get()
                )

            self._thisptr = new shared_ptr[_in.Index](
                new _eu.Euribor6M(ts_handle)
            )


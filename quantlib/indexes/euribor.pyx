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
cimport quantlib.termstructures.yields._flat_forward as _ff
cimport _euribor as _eu
cimport quantlib._index as _in


cdef class Euribor(IborIndex):
    def __init__(self):
        pass
        
cdef class Euribor6M(Euribor):
    def __init__(self):
    
        cdef Handle[_ff.YieldTermStructure] yc_handle = \
                Handle[_ff.YieldTermStructure]()

        self._thisptr = new shared_ptr[_in.Index](
            new _eu.Euribor6M(yc_handle))


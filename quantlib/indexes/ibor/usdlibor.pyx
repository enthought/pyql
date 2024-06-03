from quantlib.handle cimport Handle, shared_ptr

from cython.operator cimport dereference as deref
from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from . cimport _usdlibor as _usd
cimport quantlib._index as _in
from quantlib.time.date cimport Period


cdef class USDLibor(Libor):
    def __init__(self, Period tenor not None, HandleYieldTermStructure ts=HandleYieldTermStructure()):
        self._thisptr = shared_ptr[_in.Index](
            new _usd.USDLibor(
                deref(tenor._thisptr), ts.handle
            )
        )

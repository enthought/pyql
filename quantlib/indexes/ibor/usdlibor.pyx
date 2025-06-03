from cython.operator cimport dereference as deref
from quantlib.handle cimport HandleYieldTermStructure
from . cimport _usdlibor as _usd
cimport quantlib._index as _in
from quantlib.time.date cimport Period


cdef class USDLibor(Libor):
    def __init__(self, Period tenor not None, HandleYieldTermStructure ts=HandleYieldTermStructure()):
        self._thisptr.reset(
            new _usd.USDLibor(
                deref(tenor._thisptr), ts.handle()
            )
        )

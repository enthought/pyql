from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Period
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.indexes.swap_index cimport SwapIndex

cimport quantlib.indexes.swap._usd_libor_swap as _ls
cimport quantlib._index as _in

cdef class UsdLiborSwapIsdaFixAm(SwapIndex):
    def __init__(self, Period tenor, YieldTermStructure forwarding=YieldTermStructure(),
            YieldTermStructure discounting=YieldTermStructure()):
        self._thisptr = shared_ptr[_in.Index](
            new _ls.UsdLiborSwapIsdaFixAm(deref(tenor._thisptr),
                                          forwarding._thisptr,
                                          discounting._thisptr)
            )

cdef class UsdLiborSwapIsdaFixPm(SwapIndex):
    def __init__(self, Period tenor, YieldTermStructure forwarding=YieldTermStructure(),
            YieldTermStructure discounting=YieldTermStructure()):
        self._thisptr = shared_ptr[_in.Index](
            new _ls.UsdLiborSwapIsdaFixPm(deref(tenor._thisptr),
                                          forwarding._thisptr,
                                          discounting._thisptr)
            )

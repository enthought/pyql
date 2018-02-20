from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Period
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.indexes.swap_index cimport SwapIndex

cimport quantlib.indexes.swap._euribor_swap as _es
cimport quantlib._index as _in

cdef class EuriborSwapIsdaFixA(SwapIndex):
    def __init__(self, Period tenor, YieldTermStructure forwarding=YieldTermStructure(),
            YieldTermStructure discounting=YieldTermStructure()):
        if discounting._thisptr.empty():
             self._thisptr = shared_ptr[_in.Index](
                 new _es.EuriborSwapIsdaFixA(deref(tenor._thisptr),
                                             forwarding._thisptr))
        else:
            self._thisptr = shared_ptr[_in.Index](
                new _es.EuriborSwapIsdaFixA(deref(tenor._thisptr),
                                            forwarding._thisptr,
                                            discounting._thisptr)
            )

cdef class EuriborSwapIsdaFixB(SwapIndex):
    def __init__(self, Period tenor, YieldTermStructure forwarding=YieldTermStructure(),
            YieldTermStructure discounting=YieldTermStructure()):
        if discounting._thisptr.empty():
            self._thisptr = shared_ptr[_in.Index](
                new _es.EuriborSwapIsdaFixA(deref(tenor._thisptr),
                                            forwarding._thisptr))
        else:
            self._thisptr = shared_ptr[_in.Index](
                new _es.EuriborSwapIsdaFixB(deref(tenor._thisptr),
                                            forwarding._thisptr,
                                            discounting._thisptr)
            )

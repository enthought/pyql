from cython.operator cimport dereference as deref
from quantlib.time.date cimport Period
from quantlib.handle cimport HandleYieldTermStructure
from quantlib.indexes.swap_index cimport SwapIndex

cimport quantlib.indexes.swap._euribor_swap as _es

cdef class EuriborSwapIsdaFixA(SwapIndex):
    def __init__(self, Period tenor, HandleYieldTermStructure forwarding=HandleYieldTermStructure(),
                 HandleYieldTermStructure discounting=None):
        if discounting is None:
             self._thisptr.reset(
                 new _es.EuriborSwapIsdaFixA(deref(tenor._thisptr),
                                             forwarding.handle()))
        else:
            self._thisptr.reset(
                new _es.EuriborSwapIsdaFixA(deref(tenor._thisptr),
                                            forwarding.handle(),
                                            discounting.handle())
            )

cdef class EuriborSwapIsdaFixB(SwapIndex):
    def __init__(self, Period tenor, HandleYieldTermStructure forwarding=HandleYieldTermStructure(),
                 HandleYieldTermStructure discounting=None):
        if discounting is None:
            self._thisptr.reset(
                new _es.EuriborSwapIsdaFixA(deref(tenor._thisptr),
                                            forwarding.handle()))
        else:
            self._thisptr.reset(
                new _es.EuriborSwapIsdaFixB(deref(tenor._thisptr),
                                            forwarding.handle(),
                                            discounting.handle())
            )

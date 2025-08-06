from quantlib.handle cimport HandleYieldTermStructure
from . cimport _fedfunds as _ff
from ... cimport _index as _in

cdef class FedFunds(OvernightIndex):
    def __init__(self, HandleYieldTermStructure yts=HandleYieldTermStructure()):
        self._thisptr.reset(new _ff.FedFunds(yts.handle()))

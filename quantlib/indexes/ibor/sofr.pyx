from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from . cimport _sofr as _sfr
from ... cimport _index as _in

cdef class Sofr(OvernightIndex):
    def __init__(self, YieldTermStructure yts=YieldTermStructure()):
        self._thisptr.reset(new _sfr.Sofr(yts._thisptr))

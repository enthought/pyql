from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from . cimport _sofr as _sfr
from ... cimport _index as _in

cdef class Sofr(OvernightIndex):
    def __init__(self, HandleYieldTermStructure yts=HandleYieldTermStructure()):
        self._thisptr.reset(new _sfr.Sofr(yts.handle))

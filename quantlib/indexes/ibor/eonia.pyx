from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from . cimport _eonia as _eo
from ... cimport _index as _in

cdef class Eonia(OvernightIndex):

    def __init__(self, YieldTermStructure yts=YieldTermStructure()):
        self._thisptr.reset(new _eo.Eonia(yts._thisptr))

from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from . cimport _eonia as _eo
from ... cimport _index as _in

cdef class Eonia(OvernightIndex):

    def __init__(self, HandleYieldTermStructure yts=HandleYieldTermStructure()):
        self._thisptr.reset(new _eo.Eonia(yts.handle))

cimport quantlib.termstructures.yields._implied_term_structure as _its
from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from quantlib.time.date cimport Date

cdef class ImpliedTermStructure(YieldTermStructure):
    def __init__(self, HandleYieldTermStructure h not None,
                 Date reference_date not None):

        self._thisptr.reset(
            new _its.ImpliedTermStructure(h.handle, reference_date._thisptr)
        )

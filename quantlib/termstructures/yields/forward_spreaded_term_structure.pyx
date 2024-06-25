cimport quantlib.termstructures.yields._forward_spreaded_term_structure as _fsts

from quantlib.termstructures.yield_term_structure cimport YieldTermStructure, HandleYieldTermStructure
from quantlib.quote cimport Quote

cdef class ForwardSpreadedTermStructure(YieldTermStructure):
    """
        Constructor Inputs:
           1. YieldTermStructure
           2. Quote

    """
    def __init__(self, HandleYieldTermStructure yts not None, Quote spread not None):

        self._thisptr.reset(
            new _fsts.ForwardSpreadedTermStructure(
                yts.handle,
                spread.handle()
            )
        )

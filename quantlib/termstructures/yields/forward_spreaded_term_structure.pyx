include '../../types.pxi'

cimport quantlib.termstructures.yields._forward_spreaded_term_structure as _fsts

from quantlib.handle cimport shared_ptr
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.quote cimport Quote

cdef class ForwardSpreadedTermStructure(YieldTermStructure):
    """
        Constructor Inputs:
           1. YieldTermStructure
           2. Quote

    """
    def __init__(self, YieldTermStructure yldtermstruct not None, Quote spread not None):

        self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](new
                                         _fsts.ForwardSpreadedTermStructure(
                                             yldtermstruct._thisptr,
                                             spread.handle())
        ))

include '../../types.pxi'

from cython.operator cimport dereference as deref
from libcpp.vector cimport vector

cimport quantlib.termstructures.yields._forward_spreaded_term_structure as _fsts
cimport quantlib.termstructures.yields._flat_forward as _ff
cimport quantlib._quote as _qt

from quantlib.handle cimport shared_ptr, Handle
from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure
from quantlib.time.daycounter cimport DayCounter
from quantlib.quotes cimport Quote
from quantlib.time.date cimport Date

cdef class ForwardSpreadedTermStructure(YieldTermStructure):
    """
        Constructor Inputs:
           1. YieldTermStructure
           2. Quote

    """
    def __init__(self, YieldTermStructure yldtermstruct, Quote spread):

        cdef Handle[_qt.Quote] q_handle = Handle[_qt.Quote](spread._thisptr)

        self._thisptr.linkTo(shared_ptr[_ff.YieldTermStructure](new
                                         _fsts.ForwardSpreadedTermStructure(
                                             yldtermstruct._thisptr,
                                             q_handle)
        ))

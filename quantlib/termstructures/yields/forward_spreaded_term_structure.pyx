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
    def __init__(self,YieldTermStructure yldtermstruct, Quote spread):
        
        cdef Handle[_qt.Quote] q_handle = Handle[_qt.Quote](deref(spread._thisptr))
        cdef Handle[_ff.YieldTermStructure] yts_handle = deref(yldtermstruct._thisptr.get())
        cdef _fsts.ForwardSpreadedTermStructure* _fwdts

        _fwdts = new _fsts.ForwardSpreadedTermStructure(
                    yts_handle, 
                    q_handle
                    )
        
        self._thisptr = new shared_ptr[Handle[_ff.YieldTermStructure]](
             new Handle[_ff.YieldTermStructure](shared_ptr[_ff.YieldTermStructure](_fwdts))
        )

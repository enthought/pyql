from ..termstructure cimport TermStructure
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.handle cimport RelinkableHandle, shared_ptr

cdef class YieldTermStructure(TermStructure):
    cdef inline _yts.YieldTermStructure* as_yts_ptr(self) except NULL

cdef class HandleYieldTermStructure:
    cdef RelinkableHandle[_yts.YieldTermStructure] handle

from ..termstructure cimport TermStructure
cimport quantlib.termstructures._yield_term_structure as _yts

cdef class YieldTermStructure(TermStructure):
    cdef inline _yts.YieldTermStructure* as_yts_ptr(self) except NULL

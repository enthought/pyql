cimport quantlib.termstructures._yield_term_structure as _yts
from libcpp cimport bool as cbool
from quantlib.handle cimport RelinkableHandle

cdef class YieldTermStructure:
    cdef RelinkableHandle[_yts.YieldTermStructure] _thisptr
    cdef _yts.YieldTermStructure* _get_term_structure(self) except NULL

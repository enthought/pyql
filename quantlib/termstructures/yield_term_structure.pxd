cimport quantlib.termstructures._yield_term_structure as _yts
from libcpp cimport bool as cbool
from quantlib.handle cimport RelinkableHandle, shared_ptr
from quantlib.observable cimport Observable

cdef class YieldTermStructure(Observable):
    cdef RelinkableHandle[_yts.YieldTermStructure] _thisptr
    cdef _yts.YieldTermStructure* as_ptr(self) except NULL
    cdef shared_ptr[_yts.YieldTermStructure] as_shared_ptr(self)

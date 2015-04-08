cimport quantlib.termstructures._yield_term_structure as _yts
from libcpp cimport bool as cbool
from quantlib.handle cimport shared_ptr, Handle

cdef class YieldTermStructure:
    cdef shared_ptr[Handle[_yts.YieldTermStructure]]* _thisptr
    cdef cbool relinkable
    cdef _yts.YieldTermStructure* _get_term_structure(self)
    cdef _is_empty(self)
    cdef _raise_if_empty(self)

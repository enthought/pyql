cimport quantlib.termstructures._inflation_term_structure as _its
from libcpp cimport bool as cbool
from quantlib.handle cimport shared_ptr

cdef class InflationTermStructure:
    cdef shared_ptr[_its.InflationTermStructure] _thisptr
    cdef _its.InflationTermStructure* _get_term_structure(self)
    cdef cbool _is_empty(self)
    cdef _raise_if_empty(self)

cdef class ZeroInflationTermStructure(InflationTermStructure):
    pass

cdef class YoYInflationTermStructure(InflationTermStructure):
    pass

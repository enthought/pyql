cimport quantlib.termstructures._inflation_term_structure as _its
from quantlib.ext cimport shared_ptr

cdef class InflationTermStructure:
    cdef shared_ptr[_its.InflationTermStructure] _thisptr

cdef class ZeroInflationTermStructure(InflationTermStructure):
    pass

cdef class YoYInflationTermStructure(InflationTermStructure):
    pass

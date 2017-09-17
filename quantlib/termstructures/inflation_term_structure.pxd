cimport quantlib.termstructures._inflation_term_structure as _its
from libcpp cimport bool as cbool
from quantlib.handle cimport shared_ptr, RelinkableHandle

cdef class InflationTermStructure:
    cdef shared_ptr[_its.InflationTermStructure] _thisptr

cdef class ZeroInflationTermStructure(InflationTermStructure):
   cdef RelinkableHandle[_its.ZeroInflationTermStructure] _handle

cdef class YoYInflationTermStructure(InflationTermStructure):
   cdef RelinkableHandle[_its.YoYInflationTermStructure] _handle

cimport _rate_helpers as _rh
from quantlib.handle cimport shared_ptr

cdef class RateHelper:
    cdef shared_ptr[_rh.RateHelper]* _thisptr

cdef class RelativeDateRateHelper:
    cdef shared_ptr[_rh.RelativeDateRateHelper]* _thisptr
    

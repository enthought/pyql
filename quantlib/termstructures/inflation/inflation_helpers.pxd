cimport _inflation_helpers as _ih
from quantlib.handle cimport shared_ptr

cdef class ZeroCouponInflationSwapHelper:
    cdef shared_ptr[_ih.ZeroCouponInflationSwapHelper] _thisptr

cdef class YearOnYearInflationSwapHelper:
    cdef shared_ptr[_ih.YearOnYearInflationSwapHelper] _thisptr

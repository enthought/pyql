from libcpp.vector cimport vector
from quantlib.cashflows._dividend cimport Dividend
from quantlib.handle cimport shared_ptr

cdef class DividendSchedule:
    cdef vector[shared_ptr[Dividend]] schedule

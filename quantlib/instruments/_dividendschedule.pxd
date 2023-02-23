from libcpp.vector cimport vector
from quantlib.handle cimport shared_ptr
from quantlib.cashflows._dividend cimport Dividend

cdef extern from 'ql/instruments/dividendschedule.hpp' namespace 'QuantLib' nogil:
    ctypedef vector[shared_ptr[Dividend]] DividendSchedule

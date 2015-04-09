from quantlib.time._calendar cimport Calendar

cdef extern from 'ql/time/calendars/weekendsonly.hpp' namespace 'QuantLib':
    cdef cppclass WeekendsOnly(Calendar):
        WeekendsOnly()

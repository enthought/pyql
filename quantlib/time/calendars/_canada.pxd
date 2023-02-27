from quantlib.time._calendar cimport Calendar


cdef extern from 'ql/time/calendars/canada.hpp' namespace 'QuantLib':
    cdef cppclass Canada(Calendar):
        enum Market:
            pass
        Canada(Market mkt)

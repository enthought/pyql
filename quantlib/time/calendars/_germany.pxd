from quantlib.time._calendar cimport Calendar

cdef extern from 'ql/time/calendars/germany.hpp' namespace 'QuantLib' nogil:
    cdef cppclass Germany(Calendar):
        enum Market:
            pass
        Germany(Market mkt)


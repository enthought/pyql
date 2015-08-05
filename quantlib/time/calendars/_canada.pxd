from quantlib.time._calendar cimport Calendar

cdef extern from 'ql/time/calendars/canada.hpp' namespace \
'QuantLib::Canada':
 
    cdef enum Market:
        Settlement
        TSX

cdef extern from 'ql/time/calendars/canada.hpp' namespace 'QuantLib':
    cdef cppclass Canada(Calendar):
        Canada(Market mkt)


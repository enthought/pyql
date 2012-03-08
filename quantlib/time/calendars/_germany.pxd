from quantlib.time._calendar cimport Calendar

cdef extern from 'ql/time/calendars/germany.hpp' namespace 'QuantLib::Germany':
 
    cdef enum Market:
        Settlement
        FrankfurtStockExchange
        Xetra
        Eurex
        Euwax  


cdef extern from 'ql/time/calendars/germany.hpp' namespace 'QuantLib':
    cdef cppclass Germany(Calendar):
        Germany(Market mkt)


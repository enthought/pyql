from quantlib.time._calendar cimport Calendar

cdef extern from 'ql/time/calendars/unitedkingdom.hpp' namespace 'QuantLib::UnitedKingdom':
 
    cdef enum Market:
        Settlement
        Exchange
        Metals


cdef extern from 'ql/time/calendars/unitedkingdom.hpp' namespace 'QuantLib':
    cdef cppclass UnitedKingdom(Calendar):
        UnitedKingdom(Market mkt)


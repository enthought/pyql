from quantlib.time._calendar cimport Calendar


cdef extern from 'ql/time/calendars/unitedkingdom.hpp' namespace 'QuantLib':
    cdef cppclass UnitedKingdom(Calendar):
        enum Market:
            pass
        UnitedKingdom(Market mkt)

from quantlib.time._calendar cimport Calendar

cdef extern from 'ql/time/calendars/unitedstates.hpp' namespace 'QuantLib':
    cdef cppclass UnitedStates(Calendar):
        enum Market:
            pass
        UnitedStates(Market mkt)

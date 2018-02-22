from quantlib.time._calendar cimport Calendar

cdef extern from 'ql/time/calendars/unitedstates.hpp' namespace \
'QuantLib::UnitedStates':

    cdef enum Market:
        Settlement
        NYSE
        GovernmentBond
        NERC
        LiborImpact
        #FederalReserve

cdef extern from 'ql/time/calendars/unitedstates.hpp' namespace 'QuantLib':
    cdef cppclass UnitedStates(Calendar):
        UnitedStates(Market mkt)

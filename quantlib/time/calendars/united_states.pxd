cdef extern from 'ql/time/calendars/unitedstates.hpp' namespace \
'QuantLib::UnitedStates':

    cpdef enum class Market:
        """ US calendars"""
        Settlement # generic settlement calendar
        NYSE # New York stock exchange calendar
        GovernmentBond # government-bond calendar
        NERC # off-peak days for NERC
        LiborImpact # Libor impact calendar
        FederalReserve # Federal Reserve Bankwire System

cdef extern from 'ql/time/calendars/unitedkingdom.hpp' namespace 'QuantLib::UnitedKingdom':

    cpdef enum class Market:
        Settlement
        Exchange
        Metals

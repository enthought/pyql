cdef extern from 'ql/time/calendars/canada.hpp' namespace 'QuantLib::Canada':

    cpdef enum class Market:
        Settlement # generic settlement calendar
        TSX # Toronto stock exchange calendar

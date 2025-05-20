cdef extern from "ql/time/calendars/germany.hpp" namespace "QuantLib::Germany" nogil:
    cpdef enum class Market:
        """Germany calendar"""
        Settlement
        FrankfurtStockExchange
        Xetra
        Eurex
        Euwax

cdef extern from "ql/time/businessdayconvention.hpp" namespace "QuantLib" nogil:
    cpdef enum BusinessDayConvention:
        Following
        ModifiedFollowing
        Preceding
        ModifiedPreceding
        Unadjusted
        HalfMonthModifiedFollowing
        Nearest

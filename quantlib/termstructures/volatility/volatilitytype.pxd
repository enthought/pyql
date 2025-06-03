cdef extern from 'ql/termstructures/volatility/volatilitytype.hpp' namespace 'QuantLib' nogil:
    cpdef enum VolatilityType:
        ShiftedLognormal
        Normal

cdef extern from 'ql/termstructures/volatility/volatilitytype.hpp' namespace 'QuantLib':
    cpdef enum VolatilityType:
        ShiftedLognormal
        Normal

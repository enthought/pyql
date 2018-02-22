cdef extern from 'ql/termstructures/volatility/volatilitytype.hpp' namespace 'QuantLib':
    enum VolatilityType:
        ShiftedLognormal
        Normal

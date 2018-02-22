cimport _volatilitytype as _voltype

cpdef enum VolatilityType:
    ShiftedLognormal = _voltype.ShiftedLognormal
    Normal = _voltype.Normal

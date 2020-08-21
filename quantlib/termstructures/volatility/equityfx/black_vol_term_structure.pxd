from quantlib.handle cimport shared_ptr
from ._black_vol_term_structure cimport BlackVolTermStructure as _BlackVolTermStructure

cdef class BlackVolTermStructure:
    cdef shared_ptr[_BlackVolTermStructure] _thisptr

cdef class BlackVolatilityTermStructure(BlackVolTermStructure):
    pass

cdef class BlackVarianceTermStructure(BlackVolTermStructure):
    pass

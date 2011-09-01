cimport _black_vol_term_structure as _bv

cdef class BlackVolTermStructure:
    cdef _bv.BlackVolTermStructure* _thisptr


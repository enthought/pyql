from quantlib.handle cimport shared_ptr
cimport _black_vol_term_structure as _bv

cdef class BlackVolTermStructure:
    cdef shared_ptr[_bv.BlackVolTermStructure]* _thisptr


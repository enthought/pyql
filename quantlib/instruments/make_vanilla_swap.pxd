include '../types.pxi'

cimport quantlib.instruments._make_vanilla_swap as _make_vanilla_swap

cdef class MakeVanillaSwap:
    cdef _make_vanilla_swap.MakeVanillaSwap* _thisptr

include '../types.pxi'

cimport _make_vanilla_swap

cdef class MakeVanillaSwap:
    cdef _make_vanilla_swap.MakeVanillaSwap* _thisptr

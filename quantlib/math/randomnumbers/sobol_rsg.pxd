from . cimport _sobol_rsg

cdef class SobolRsg:
    cdef _sobol_rsg.SobolRsg* _thisptr

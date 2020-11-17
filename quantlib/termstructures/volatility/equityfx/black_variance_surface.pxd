from .black_vol_term_structure cimport BlackVarianceTermStructure

cpdef enum Interpolator:
    Bilinear
    Bicubic

cdef class BlackVarianceSurface(BlackVarianceTermStructure):
    pass

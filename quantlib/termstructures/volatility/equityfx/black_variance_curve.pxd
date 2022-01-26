from .black_vol_term_structure cimport BlackVarianceTermStructure
from . cimport _black_variance_curve as _bvc

cdef class BlackVarianceCurve(BlackVarianceTermStructure):
    cdef inline _bvc.BlackVarianceCurve* get_bvc(self)

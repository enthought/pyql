from .swaption_vol_discrete cimport SwaptionVolatilityDiscrete
from . cimport _swaption_vol_matrix as _svm

cdef class SwaptionVolatilityMatrix(SwaptionVolatilityDiscrete):
    pass

from . cimport _swaption_vol_discrete as _svd
from .swaption_vol_structure cimport SwaptionVolatilityStructure

cdef class SwaptionVolatilityDiscrete(SwaptionVolatilityStructure):
    pass

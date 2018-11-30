from ...vol_term_structure cimport VolatilityTermStructure
from . cimport _swaption_vol_structure as _svs

cdef class SwaptionVolatilityStructure(VolatilityTermStructure):
    cdef inline _svs.SwaptionVolatilityStructure* get_svs(self)

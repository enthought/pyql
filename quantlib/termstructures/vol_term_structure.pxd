from ..termstructure cimport TermStructure
from . cimport _vol_term_structure as _vts

cdef class VolatilityTermStructure(TermStructure):
    cdef _vts.VolatilityTermStructure* as_vol_ts(self) noexcept nogil

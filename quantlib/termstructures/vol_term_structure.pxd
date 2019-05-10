from quantlib.handle cimport shared_ptr
from . cimport _vol_term_structure as _vts

cdef class VolatilityTermStructure:
    cdef shared_ptr[_vts.VolatilityTermStructure] _thisptr

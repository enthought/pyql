cimport _swaption_vol_structure as _svs
from quantlib.handle cimport shared_ptr

cdef class SwaptionVolatilityStructure:
    cdef shared_ptr[_svs.SwaptionVolatilityStructure] _thisptr

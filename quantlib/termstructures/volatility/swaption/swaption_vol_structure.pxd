from libcpp cimport bool
from quantlib.handle cimport shared_ptr, Handle, RelinkableHandle
from ...vol_term_structure cimport VolatilityTermStructure
from . cimport _swaption_vol_structure as _svs

cdef class SwaptionVolatilityStructure(VolatilityTermStructure):
    cdef shared_ptr[_svs.SwaptionVolatilityStructure] _derived_ptr
    cdef inline _svs.SwaptionVolatilityStructure* get_svs(self) nogil
    @staticmethod
    cdef Handle[_svs.SwaptionVolatilityStructure] swaption_vol_handle(object vol)

cdef class HandleSwaptionVolatilityStructure:
    cdef RelinkableHandle[_svs.SwaptionVolatilityStructure] handle

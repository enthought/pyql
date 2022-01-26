from libcpp cimport bool as cbool
from quantlib.handle cimport Handle, RelinkableHandle, shared_ptr
from . cimport _vol_term_structure as _vts

cdef class VolatilityTermStructure:
    cdef shared_ptr[_vts.VolatilityTermStructure] _thisptr
    cdef _vts.VolatilityTermStructure* as_ptr(self) nogil
    @staticmethod
    cdef Handle[_vts.VolatilityTermStructure] handle(object vol)

cdef class HandleVolatilityTermStructure:
    cdef RelinkableHandle[_vts.VolatilityTermStructure] handle

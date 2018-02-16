from quantlib.handle cimport shared_ptr
cimport quantlib.termstructures.volatility.swaption._swaptionvolcube as _svc

cdef class SwaptionVolatilityCube:
    cdef shared_ptr[_svc.SwaptionVolatilityCube] _thisptr

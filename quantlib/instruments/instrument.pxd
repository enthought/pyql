from quantlib.handle cimport shared_ptr
cimport _instrument

cdef class Instrument:
    cdef shared_ptr[_instrument.Instrument]* _thisptr

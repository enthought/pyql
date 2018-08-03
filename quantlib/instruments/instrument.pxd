from quantlib.handle cimport shared_ptr
from quantlib.observable cimport Observable
cimport _instrument

cdef class Instrument(Observable):
    cdef shared_ptr[_instrument.Instrument] _thisptr

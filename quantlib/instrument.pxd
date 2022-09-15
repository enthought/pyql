from quantlib.handle cimport shared_ptr
from quantlib.observable cimport Observable
from . cimport _instrument

cdef class Instrument(Observable):
    cdef shared_ptr[_instrument.Instrument] _thisptr

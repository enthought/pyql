from quantlib.instruments.instrument cimport Instrument

cdef class Swap(Instrument):
    pass

cdef class VanillaSwap(Swap):
    pass

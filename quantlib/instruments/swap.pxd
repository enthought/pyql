from quantlib.instruments.instrument cimport Instrument

cpdef enum SwapType:
    Receiver = -1
    Payer    = 1

cdef class Swap(Instrument):
    pass

cdef class VanillaSwap(Swap):
    pass

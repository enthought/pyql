from quantlib.instruments.instrument cimport Instrument
from . cimport _swap

cpdef enum SwapType:
    Receiver = _swap.Receiver
    Payer    = _swap.Payer

cdef class Swap(Instrument):
    pass

cdef class VanillaSwap(Swap):
    pass

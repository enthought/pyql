from ..instrument cimport Instrument

cdef extern from "ql/instruments/swap.hpp" namespace "QuantLib::Swap" nogil:
    cpdef enum SwapType "QuantLib::Swap::Type":
        Receiver
        Payer

cdef class Swap(Instrument):
    pass

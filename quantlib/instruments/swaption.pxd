from ._swaption cimport Settlement
from .instrument cimport Instrument

cpdef enum SettlementType:
    Physical
    Cash

cdef class Swaption(Instrument):
    pass

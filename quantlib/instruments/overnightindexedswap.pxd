from . cimport _overnightindexedswap as _ois
from .swap cimport Swap

cdef extern from 'ql/instruments/overnightindexedswap.hpp' namespace 'QuantLib::OvernightIndexedSwap':
    cpdef enum Type "QuantLib::OvernightIndexedSwap::Type":
        Receiver
        Payer

cdef class OvernightIndexedSwap(Swap):
    pass

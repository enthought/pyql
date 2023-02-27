from ..instrument cimport Instrument

cdef extern from 'ql/instruments/creditdefaultswap.hpp' namespace 'QuantLib::CreditDefaultSwap':
    cpdef enum class PricingModel:
        Midpoint
        ISDA

cdef class CreditDefaultSwap(Instrument):
    pass

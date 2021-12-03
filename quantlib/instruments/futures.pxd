cdef extern from 'ql/instruments/futures.hpp' namespace 'QuantLib::Futures':
    cpdef enum FuturesType "QuantLib::Futures::Type":
        IMM
        ASX

cdef extern from 'ql/cashflows/rateaveraging.hpp' namespace 'QuantLib::RateAveraging':
    cpdef enum RateAveraging "QuantLib::RateAveraging::Type":
            Simple
            Compound

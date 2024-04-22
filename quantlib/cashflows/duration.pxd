cdef extern from "ql/cashflows/duration.hpp" namespace "QuantLib::Duration" nogil:
    cpdef enum Duration "QuantLib::Duration::Type":
        Simple
        Macaulay
        Modified

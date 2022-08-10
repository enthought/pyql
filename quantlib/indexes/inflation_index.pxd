from quantlib.index cimport Index

cdef extern from "ql/indexes/inflationindex.hpp" namespace "QuantLib::CPI" nogil:
    cpdef enum InterpolationType "QuantLib::CPI::InterpolationType":
        AsIndex
        Flat
        Linear

cdef class InflationIndex(Index):
    pass

cdef class ZeroInflationIndex(InflationIndex):
    pass

cdef class AUCPI(ZeroInflationIndex):
    pass

cdef class YoYInflationIndex(ZeroInflationIndex):
    pass

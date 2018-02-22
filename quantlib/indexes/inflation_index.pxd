from quantlib.index cimport Index

cdef class InflationIndex(Index):
    pass

cdef class ZeroInflationIndex(InflationIndex):
    pass

cdef class AUCPI(ZeroInflationIndex):
    pass

cdef class YoYInflationIndex(ZeroInflationIndex):
    pass

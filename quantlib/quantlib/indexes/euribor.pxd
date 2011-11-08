from quantlib.indexes.ibor_index cimport IborIndex

cdef class Euribor(IborIndex):
    pass

cdef class Euribor6M(Euribor):
    pass


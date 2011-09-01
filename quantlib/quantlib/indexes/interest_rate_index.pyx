cimport _interest_rate_index

from quantlib.index cimport Index

cdef class InterestRateIndex(Index):

    def __cinit__(self):
        pass

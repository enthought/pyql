from quantlib.indexes.interest_rate_index cimport InterestRateIndex

cdef class SwapIndex(InterestRateIndex):
    pass

cdef class OvernightIndexedSwapIndex(SwapIndex):
    pass

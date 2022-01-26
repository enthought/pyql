from .rate_helpers cimport RelativeDateRateHelper, RateHelper

cdef class OISRateHelper(RelativeDateRateHelper):
    pass

cdef class DatedOISRateHelper(RateHelper):
    pass

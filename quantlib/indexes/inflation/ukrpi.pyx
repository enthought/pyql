from . cimport _ukrpi

from quantlib.indexes.inflation_index cimport ZeroInflationIndex
from quantlib.termstructures.inflation_term_structure \
    cimport ZeroInflationTermStructure

cdef class UKRPI(ZeroInflationIndex):
    def __init__(self, ZeroInflationTermStructure ts=ZeroInflationTermStructure()):
        self._thisptr.reset(new _ukrpi.UKRPI(ts._handle))

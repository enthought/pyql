from . cimport _ukrpi

from quantlib.indexes.inflation_index cimport ZeroInflationIndex
from quantlib.handle cimport HandleZeroInflationTermStructure

cdef class UKRPI(ZeroInflationIndex):
    def __init__(self, HandleZeroInflationTermStructure ts=HandleZeroInflationTermStructure()):
        self._thisptr.reset(new _ukrpi.UKRPI(ts.handle()))

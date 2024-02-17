from libcpp cimport bool
from . cimport _aucpi
from quantlib.time.frequency cimport Frequency
from quantlib.termstructures.inflation_term_structure cimport ZeroInflationTermStructure

cdef class AUCPI(ZeroInflationIndex):
    def __init__(self,
                 Frequency frequency,
                 bool revised,
                 ZeroInflationTermStructure ts=ZeroInflationTermStructure()):
        self._thisptr.reset(new _aucpi.AUCPI(frequency, revised, ts._handle))

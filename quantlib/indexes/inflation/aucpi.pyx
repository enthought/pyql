from libcpp cimport bool
from . cimport _aucpi
from quantlib.time.frequency cimport Frequency
from quantlib.handle cimport HandleZeroInflationTermStructure

cdef class AUCPI(ZeroInflationIndex):
    def __init__(self,
                 Frequency frequency,
                 bool revised,
                 HandleZeroInflationTermStructure ts=HandleZeroInflationTermStructure()):
        self._thisptr.reset(new _aucpi.AUCPI(frequency, revised, ts.handle()))

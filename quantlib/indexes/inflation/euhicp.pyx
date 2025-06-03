from . cimport _euhicp
from libcpp cimport bool
from quantlib.handle cimport (
    HandleZeroInflationTermStructure, HandleYoYInflationTermStructure)

cdef class EUHICP(ZeroInflationIndex):
    def __init__(self, HandleZeroInflationTermStructure ts=HandleZeroInflationTermStructure()):
        self._thisptr.reset(new _euhicp.EUHICP(ts.handle()))


cdef class EUHICPXT(ZeroInflationIndex):
    def __init__(self, HandleZeroInflationTermStructure ts=HandleZeroInflationTermStructure()):
        self._thisptr.reset(new _euhicp.EUHICPXT(ts.handle()))

cdef class YYEUHICP(YoYInflationIndex):
    def __init__(self, HandleYoYInflationTermStructure ts=HandleYoYInflationTermStructure()):
        self._thisptr.reset(new _euhicp.YYEUHICP(ts.handle()))

cdef class YYEUHICPXT(YoYInflationIndex):
    def __init__(self, HandleYoYInflationTermStructure ts=HandleYoYInflationTermStructure()):
        self._thisptr.reset(new _euhicp.YYEUHICPXT(ts.handle()))

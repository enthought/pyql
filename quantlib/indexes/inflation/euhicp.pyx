from . cimport _euhicp
from libcpp cimport bool
from quantlib.termstructures.inflation_term_structure cimport (
    ZeroInflationTermStructure, YoYInflationTermStructure)

cdef class EUHICP(ZeroInflationIndex):
    def __init__(self, ZeroInflationTermStructure ts=ZeroInflationTermStructure()):
        self._thisptr.reset(new _euhicp.EUHICP(ts._handle))


cdef class EUHICPXT(ZeroInflationIndex):
    def __init__(self, ZeroInflationTermStructure ts=ZeroInflationTermStructure()):
        self._thisptr.reset(new _euhicp.EUHICPXT(ts._handle))

cdef class YYEUHICP(YoYInflationIndex):
    def __init__(self, YoYInflationTermStructure ts=YoYInflationTermStructure()):
        self._thisptr.reset(new _euhicp.YYEUHICP(ts._handle))

cdef class YYEUHICPXT(YoYInflationIndex):
    def __init__(self, YoYInflationTermStructure ts=YoYInflationTermStructure()):
        self._thisptr.reset(new _euhicp.YYEUHICPXT(ts._handle))

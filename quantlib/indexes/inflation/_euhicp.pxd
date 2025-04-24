from libcpp cimport bool
from .._inflation_index cimport ZeroInflationIndex, YoYInflationIndex
from quantlib.handle cimport Handle
from quantlib.termstructures._inflation_term_structure cimport ZeroInflationTermStructure, YoYInflationTermStructure

cdef extern from 'ql/indexes/inflation/euhicp.hpp' namespace 'QuantLib' nogil:
    cdef cppclass EUHICP(ZeroInflationIndex):
        EUHICP(const Handle[ZeroInflationTermStructure]& ts)

    cdef cppclass EUHICPXT(ZeroInflationIndex):
        EUHICPXT(const Handle[ZeroInflationTermStructure]& ts)

    cdef cppclass YYEUHICP(YoYInflationIndex):
        YYEUHICP(const Handle[YoYInflationTermStructure]& ts)

    cdef cppclass YYEUHICPXT(YoYInflationIndex):
        YYEUHICPXT(const Handle[YoYInflationTermStructure]& ts)

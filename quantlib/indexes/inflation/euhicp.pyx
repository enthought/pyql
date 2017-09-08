from libcpp cimport bool

from quantlib.currency.api import EURCurrency
from quantlib.indexes.regions import EURegion
from quantlib.indexes.inflation_index cimport (
    ZeroInflationIndex, YoYInflationIndex)
from quantlib.time.frequency cimport Monthly
from quantlib.time._period cimport Months
from quantlib.time.date cimport Period
from quantlib.termstructures.inflation_term_structure cimport (
    ZeroInflationTermStructure, YoYInflationTermStructure)

cdef class EUHICP(ZeroInflationIndex):
    def __init__(self, bool interpolated,
                 ZeroInflationTermStructure ts=ZeroInflationTermStructure()):

        super().__init__("HICP", EURegion(), False,
                         interpolated, Monthly, Period(1, Months),
                         EURCurrency(), ts)


cdef class EUHICPXT(ZeroInflationIndex):
    def __init__(self, bool interpolated,
                 ZeroInflationTermStructure ts=ZeroInflationTermStructure()):

        super().__init__("HICPXT", EURegion(), False,
                         interpolated, Monthly, Period(1, Months),
                         EURCurrency(), ts)

cdef class YYEUHICP(YoYInflationIndex):
    def __init__(self, bool interpolated,
                 YoYInflationTermStructure ts=YoYInflationTermStructure()):

        super().__init__("YY_HICP", EURegion(), False,
                         interpolated, Monthly, Period(1, Months),
                         EURCurrency(), ts)

cdef class YYEUHICPXT(YoYInflationIndex):
    def __init__(self, bool interpolated,
                 YoYInflationTermStructure ts=YoYInflationTermStructure()):

        super().__init__("YY_HICPXT", EURegion(), False,
                         interpolated, Monthly, Period(1, Months),
                         EURCurrency(), ts)

from libcpp cimport bool

from quantlib.currency.api import GBPCurrency
from quantlib.indexes.regions import UKRegion
from quantlib.time.date cimport Period
from quantlib.time.date import Months
from quantlib.time.frequency cimport Monthly
from quantlib.indexes.inflation_index cimport ZeroInflationIndex
from quantlib.termstructures.inflation_term_structure \
    cimport ZeroInflationTermStructure

cdef class UKRPI(ZeroInflationIndex):
    def __init__(self, bool interpolated,
                 ZeroInflationTermStructure ts=ZeroInflationTermStructure()):

        super().__init__("RPI", UKRegion(), False,
                         interpolated, Monthly, Period(1, Months),
                         GBPCurrency(), ts)

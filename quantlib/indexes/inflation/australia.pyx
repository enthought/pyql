from libcpp cimport bool

from quantlib.currency.api import AUDCurrency
from quantlib.indexes.regions import AustraliaRegion
from quantlib.indexes.inflation_index cimport ZeroInflationIndex
from quantlib.time._period cimport Frequency, Months
from quantlib.time.date cimport Period
from quantlib.termstructures.inflation_term_structure cimport ZeroInflationTermStructure

cdef class AUCPI(ZeroInflationIndex):
    def __init__(self, Frequency frequency,
                 bool revised,
                 bool interpolated,
                 ZeroInflationTermStructure ts=ZeroInflationTermStructure()):

        super().__init__("CPI", AustraliaRegion(), revised,
                         interpolated, frequency, Period(2, Months),
                         AUDCurrency(), ts)

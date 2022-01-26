from quantlib.types cimport Real
from quantlib.cashflows.rateaveraging cimport RateAveraging
from ._rate_helpers cimport RateHelper
from quantlib.handle cimport Handle, shared_ptr
from quantlib.indexes._ibor_index cimport OvernightIndex
from quantlib.time._date cimport Date, Month, Year
from quantlib.time.frequency cimport Frequency
from quantlib._quote cimport Quote

cdef extern from 'ql/termstructures/yield/overnightindexfutureratehelper.hpp' namespace 'QuantLib':
    cdef cppclass OvernightIndexFutureRateHelper(RateHelper):
        OvernightIndexFutureRateHelper(
            Handle[Quote]& price,
            Date& value_date, # first day of reference period
            Date& maturity_date, # delivery Date
            shared_ptr[OvernightIndex] overnightIndex,
            Handle[Quote] convexityAdjustment, # = Handle[Quote](),
            RateAveraging averagingMethod)# = RateAveraging.Compound);

        Real convexityAdjustment()

    cdef cppclass SofrFutureRateHelper(OvernightIndexFutureRateHelper):
        SofrFutureRateHelper(Handle[Quote]& price,
                             Month referenceMonth,
                             Year referenceYear,
                             Frequency referenceFreq,
                             shared_ptr[OvernightIndex]& overnightIndex,
                             Handle[Quote]& convexityAdjustment, # = Handle<Quote>(),
                             RateAveraging averagingMethod) # = RateAveraging::Compound)
        SofrFutureRateHelper(Real price,
                             Month referenceMonth,
                             Year referenceYear,
                             Frequency referenceFreq,
                             shared_ptr[OvernightIndex]& overnightIndex,
                             Real convexityAdjustment, # = 0,
                             RateAveraging averagingMethod) # = RateAveraging::Compound)

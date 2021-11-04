from libcpp cimport bool
from quantlib.types cimport Real
from quantlib.cashflows.rateaveraging cimport RateAveraging
from quantlib.handle cimport Handle, shared_ptr
from quantlib.indexes._ibor_index cimport OvernightIndex
from quantlib.instruments._instrument cimport Instrument
from quantlib._quote cimport Quote
from quantlib.time._date cimport Date

cdef extern from 'ql/instruments/overnightindexfuture.hpp' namespace 'QuantLib':
    cdef cppclass OvernightIndexFuture(Instrument):

        OvernightIndexFuture(
            shared_ptr[OvernightIndex] overnightIndex,
            const Date& valueDate,
            const Date& maturityDate,
            Handle[Quote] convexityAdjustment, # = Handle[Quote](),
            RateAveraging averagingMethod)# = RateAveraging.Compound);

        Real convexityAdjustment()
        bool isExpired()

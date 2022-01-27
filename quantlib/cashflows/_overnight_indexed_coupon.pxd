from quantlib.types cimport Rate, Real, Spread, Time

from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.handle cimport shared_ptr
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.indexes._ibor_index cimport OvernightIndex
from ._floating_rate_coupon cimport FloatingRateCoupon
from .rateaveraging cimport RateAveraging

cdef extern from 'ql/cashflows/overnightindexedcoupon.hpp' namespace 'QuantLib':
    cdef cppclass OvernightIndexedCoupon(FloatingRateCoupon):
        OvernightIndexedCoupon(const Date& paymentDate,
                               Real nominal,
                               const Date& startDate,
                               const Date& endDate,
                               const shared_ptr[OvernightIndex] index,
                               Real gearing, #= 1.0,
                               Spread spread, #= 0.0,
                               const Date& refPeriodStart, #= Date(),
                               const Date& refPeriodEnd, #= Date(),
                               const DayCounter& dayCounter, #= DayCounter(),
                               bool telescopicValueDates, #=False,
                               RateAveraging averagingMethod) # = RateAveraging::Compound

        vector[Date]& fixingDates()
        vector[Time]& dt
        vector[Rate]& indexFixings()
        vector[Date]& valueDates()

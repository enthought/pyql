from quantlib.types cimport Integer, Natural, Rate, Real, Spread, Time

from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.handle cimport shared_ptr
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._schedule cimport Schedule
from quantlib.time._calendar cimport Calendar
from quantlib.time.businessdayconvention cimport BusinessDayConvention

from quantlib.indexes._ibor_index cimport OvernightIndex
from ._floating_rate_coupon cimport FloatingRateCoupon
from .rateaveraging cimport RateAveraging

cdef extern from 'ql/cashflows/overnightindexedcoupon.hpp' namespace 'QuantLib' nogil:
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
                               RateAveraging averagingMethod, # = RateAveraging::Compound
                               Natural lookback_days,
                               Natural lockout_days,
                               bool apply_observation_shift)

        vector[Date]& fixingDates()
        vector[Time]& dt()
        vector[Rate]& indexFixings() except +
        vector[Date]& valueDates()
        RateAveraging averagingMethod()
        Natural lockoutDays()
        bool applyObservationShift()

    cdef cppclass OvernightLeg:
        OvernightLeg(Schedule schedule, shared_ptr[OvernightIndex] overnightIndex)
        OvernightLeg& withNotionals(Real notional)
        OvernightLeg& withPaymentDayCounter(DayCounter dc)
        OvernightLeg& withPaymentAdjustment(BusinessDayConvention)
        OvernightLeg& withPaymentCalendar(Calendar)
        OvernightLeg& withPaymentLag(Integer Lag)
        OvernightLeg& withSpreads(Real spread)
        OvernightLeg& withObservationShift(bool)
        OvernightLeg& withLookbackDays(Natural)
        OvernightLeg& withLockoutDays(Natural)

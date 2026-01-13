from quantlib.types cimport Integer, Natural, Rate, Real, Spread, Time

from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.ext cimport shared_ptr, optional
from quantlib.time._date cimport Date
from quantlib.time._period cimport Period
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._schedule cimport Schedule
from quantlib.time._calendar cimport Calendar
from quantlib.time.businessdayconvention cimport BusinessDayConvention

from quantlib.indexes._ibor_index cimport OvernightIndex
from ._floating_rate_coupon cimport FloatingRateCoupon
from ._overnight_indexed_coupon_pricer cimport OvernightIndexedCouponPricer
from .rateaveraging cimport RateAveraging
from .._cashflow cimport Leg

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
                               Natural lookback_days, # = Null<Natural>
                               Natural lockout_days, # = 0
                               bool apply_observation_shift, #+ False
                               bool compound_spread, # = False
                               )

        vector[Date]& fixingDates()
        vector[Time]& dt()
        vector[Rate]& indexFixings() except +
        vector[Date]& valueDates()
        RateAveraging averagingMethod()
        Natural lockoutDays()
        bool applyObservationShift()
        bool compoundSpreadDaily()
        Real effectiveSpread()
        Real effectiveIndexFixing()


    cdef cppclass OvernightLeg:
        OvernightLeg(Schedule schedule, shared_ptr[OvernightIndex] overnightIndex)
        OvernightLeg& withNotionals(Real notional)
        OvernightLeg& withPaymentDayCounter(DayCounter dc)
        OvernightLeg& withPaymentAdjustment(BusinessDayConvention)
        OvernightLeg& withPaymentCalendar(Calendar)
        OvernightLeg& withPaymentLag(Integer Lag)
        OvernightLeg& withSpreads(Real spread)
        OvernightLeg& withSpreads(const vector[Spread]& spreads)
        OvernightLeg& withTelescopicValueDates(bool telescopicValueDates)
        OvernightLeg& withAveragingMethod(RateAveraging averagingMethod)
        OvernightLeg& withLookbackDays(Natural)
        OvernightLeg& withLockoutDays(Natural)
        OvernightLeg& withObservationShift(bool applyObservationShift) # = true);
        OvernightLeg& compoundingSpreadDaily(bool compoundSpreadDaily) # = true);
        OvernightLeg& withLookback(const Period& lookback)
        OvernightLeg& withCaps(Rate cap)
        OvernightLeg& withCaps(const vector[Rate]& caps)
        OvernightLeg& withFloors(Rate floor)
        OvernightLeg& withFloors(const vector[Rate]& floors);
        OvernightLeg& withNakedOption(bool nakedOption)
        OvernightLeg& withDailyCapFloor(bool dailyCapFloor) # = true);
        OvernightLeg& inArrears(bool inArrears)
        OvernightLeg& withLastRecentPeriod(const optional[Period]& lastRecentPeriod)
        OvernightLeg& withLastRecentPeriodCalendar(const Calendar& lastRecentPeriodCalendar)
        OvernightLeg& withPaymentDates(const vector[Date]& paymentDates)
        OvernightLeg& withCouponPricer(const shared_ptr[OvernightIndexedCouponPricer]& couponPricer)
        Leg operator() const

cdef extern from 'ql/cashflows/overnightindexedcoupon.hpp':
    # this allows to declare the cast operator as raising exceptions
    """
    #define to_leg(x) static_cast<QuantLib::Leg>(x)
    """
    cdef Leg to_leg(OvernightLeg) except +

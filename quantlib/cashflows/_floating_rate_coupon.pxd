include '../types.pxi'

from libcpp cimport bool
from quantlib.handle cimport shared_ptr
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib._cashflow cimport CashFlow
from quantlib._interest_rate cimport InterestRate
from quantlib.cashflows._coupon cimport Coupon
from _coupon_pricer cimport FloatingRateCouponPricer
from quantlib.indexes._interest_rate_index cimport InterestRateIndex

cdef extern from 'ql/cashflows/floatingratecoupon.hpp' namespace 'QuantLib':
    cdef cppclass FloatingRateCoupon(Coupon):
        FloatingRateCoupon(const Date& paymentDate,
                           Real nominal,
                           const Date& startDate,
                           const Date& endDate,
                           Natural fixingDays,
                           const shared_ptr[InterestRateIndex] index,
                           Real gearing, #= 1.0,
                           Spread spread, #= 0.0,
                           const Date& refPeriodStart, #= Date(),
                           const Date& refPeriodEnd, #= Date(),
                           const DayCounter& dayCounter, #= DayCounter(),
                           bool isInArrears) #=false

        const shared_ptr[InterestRateIndex]& index()
        Natural fixingDays()
        Date fixingDate()
        Real gearing()
        Spread spread()
        Rate indexFixing()
        Rate convexityAdjustment()
        Rate adjustedFixing()
        bool isInArrears()
        void setPricer(const shared_ptr[FloatingRateCouponPricer]&)

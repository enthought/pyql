include '../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.time._date cimport Date
from quantlib.time._period cimport Frequency, Period
from quantlib.time._calendar cimport Calendar
from quantlib.compounding cimport Compounding
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._schedule cimport Schedule
from quantlib._cashflow cimport CashFlow
from quantlib._interest_rate cimport InterestRate
from quantlib.cashflows._coupon cimport Coupon
from .._cashflow cimport Leg

cdef extern from 'ql/cashflows/fixedratecoupon.hpp' namespace 'QuantLib':

    cdef cppclass FixedRateCoupon(Coupon):
        FixedRateCoupon(const Date& paymentDate,
                        Real nominal,
                        Rate rate,
                        const DayCounter& dayCounter,
                        const Date& accrualStartDate,
                        const Date& accrualEndDate,
                        const Date& refPeriodStart,# = Date(),
                        const Date& refPeriodEnd, # = Date(),
                        const Date& exCouponDate) # = Date()
        FixedRateCoupon(const Date& paymentDate,
                        Real nominal,
                        const InterestRate& interestRate,
                        const Date& accrualStartDate,
                        const Date& accrualEndDate,
                        const Date& refPeriodStart, # = Date(),
                        const Date& refPeriodEnd, #= Date(),
                        const Date& exCouponDate)  #= Date()
        InterestRate interestRate()

    cdef cppclass FixedRateLeg:
         FixedRateLeg(const Schedule& schedule)
         FixedRateLeg& withNotionals(Real)
         FixedRateLeg& withNotionals(const vector[Real]&)
         FixedRateLeg& withCouponRates(Rate,
                                       const DayCounter& paymentDayCounter,
                                       Compounding comp,# = Simple,
                                       Frequency freq) # = Annual)
         FixedRateLeg& withCouponRates(const vector[Rate]&,
                                       const DayCounter& paymentDayCounter,
                                       Compounding comp,# = Simple,
                                       Frequency freq) # = Annual
         FixedRateLeg& withCouponRates(const InterestRate&) except +
         FixedRateLeg& withCouponRates(const vector[InterestRate]&)
         FixedRateLeg& withPaymentAdjustment(BusinessDayConvention)
         FixedRateLeg& withFirstPeriodDayCounter(const DayCounter&)
         FixedRateLeg& withLastPeriodDayCounter(const DayCounter&)
         FixedRateLeg& withPaymentCalendar(const Calendar&)
         FixedRateLeg& withPaymentLag(Natural lag)
         FixedRateLeg& withExCouponPeriod(const Period&,
                                          const Calendar&,
                                          BusinessDayConvention,
                                          bool endOfMonth)# = false)

cdef extern from 'ql/cashflows/fixedratecoupon.hpp':
    """
    #define to_leg(x) static_cast<QuantLib::Leg>(x)
    """
    cdef Leg to_leg(FixedRateLeg) except +

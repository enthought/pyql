include '../types.pxi'

from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib._cashflow cimport CashFlow
from quantlib._interest_rate cimport InterestRate
from quantlib.cashflows._coupon cimport Coupon

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

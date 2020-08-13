from quantlib.types cimport *

from quantlib.time._date cimport Date, serial_type
from quantlib.time._daycounter cimport DayCounter
from quantlib._cashflow cimport CashFlow
from quantlib._interest_rate cimport InterestRate

cdef extern from 'ql/cashflows/coupon.hpp' namespace 'QuantLib':
    cdef cppclass Coupon(CashFlow):
        Coupon(const Date& paymentDate,
               Real nominal,
               const Date& accrualStartDate,
               const Date& accrualEndDate,
               const Date& refPeriodStart = Date(),
               const Date& refPeriodEnd = Date(),
               const Date& exCouponDate = Date())
        Date date()
        Date exCouponDate()
        Real nominal()
        const Date& accrualStartDate()
        const Date& accrualEndDate()
        const Date& referencePeriodStart()
        const Date& referencePeriodEnd()
        Time accrualPeriod()
        serial_type accrualDays()
        Rate rate() except +
        DayCounter dayCounter()
        Time accruedPeriod(const Date&)
        serial_type accruedDays(const Date&)
        Real accruedAmount(const Date&)

include '../types.pxi'
from libcpp cimport bool
from quantlib.handle cimport shared_ptr
from quantlib.indexes._ibor_index cimport IborIndex
from quantlib.indexes._swap_index cimport SwapIndex
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from _floating_rate_coupon cimport FloatingRateCoupon
from _coupon_pricer cimport FloatingRateCouponPricer

cdef extern from 'ql/cashflows/capflooredcoupon.hpp' namespace 'QuantLib':
    # Capped and/or floored floating-rate coupon
    # The payoff $P$ of a capped floating-rate coupon is:
    # \[ P = N \times T \times \min(a L + b, C). \]
    # The payoff of a floored floating-rate coupon is:
    # \[ P = N \times T \times \max(a L + b, F). \]
    # The payoff of a collared floating-rate coupon is:
    # \[ P = N \times T \times \min(\max(a L + b, F), C). \]
    # where $N$ is the notional, $T$ is the accrual
    # time, $L$ is the floating rate, $ a$ is its
    # gearing, $b$ is the spread, and $C$ and $F$
    # the strikes.
    # They can be decomposed in the following manner.
    # Decomposition of a capped floating rate coupon:
    # \[
    #     R = \min(a L + b, C) = (a L + b) + \min(C - b - \xi |a| L, 0)
    # \]
    # where \$\xi = sgn(a)$. Then:
    # \[
    #    R = (a L + b) + |a| \min(\frac{C - b}{|a|} - \xi L, 0)
    # \]

    cdef cppclass CappedFlooredCoupon(FloatingRateCoupon):
        CappedFlooredCoupon(
            shared_ptr[FloatingRateCoupon]& underlying,
            Rate cap, # = Null<Rate>()
            Rate floor) # = Null<Rate>()
        Rate cap()
        Rate floor()
        Rate effetiveCap()
        Rate effectiveFloored()
        bool isCapped()
        bool isFloored()
        void setPricer(const shared_ptr[FloatingRateCouponPricer]&)

    cdef cppclass CappedFlooredIborCoupon(CappedFlooredCoupon):
        CappedFlooredIborCoupon(
            const Date& paymentDate,
            Real nominal,
            const Date& startDate,
            const Date& endDate,
            Natural fixingDays,
            const shared_ptr[IborIndex]& index,
            Real gearing, # = 1.0,
            Spread spread, # = 0.0,
            Rate cap, # = Null<Rate>(),
            Rate floor,# = Null<Rate>(),
            const Date& refPeriodStart, # = Date(),
            const Date& refPeriodEnd, # = Date(),
            const DayCounter& dayCounter,# = DayCounter(),
            bool isInArrears # = false
            ) except +

    cdef cppclass CappedFlooredCmsCoupon(CappedFlooredCoupon):
        CappedFlooredCmsCoupon(
            const Date& paymentDate,
            Real nominal,
            const Date& startDate,
            const Date& endDate,
            Natural fixingDays,
            const shared_ptr[SwapIndex]& index,
            Real gearing, # = 1.0,
            Spread spread, # = 0.0,
            Rate cap, # = Null<Rate>(),
            Rate floor, # = Null<Rate>(),
            const Date& refPeriodStart, # = Date(),
            const Date& refPeriodEnd, # = Date(),
            const DayCounter& dayCounter, # = DayCounter(),
            bool isInArrears # = false
        ) except +

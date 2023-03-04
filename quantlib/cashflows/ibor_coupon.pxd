from quantlib.cashflows.floating_rate_coupon cimport FloatingRateCoupon
from quantlib.cashflow cimport Leg

cdef class IborCoupon(FloatingRateCoupon):
    pass

cdef class IborLeg(Leg):
    pass

cdef class IborCouponSettings:
    pass

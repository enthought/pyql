from .floating_rate_coupon cimport FloatingRateCoupon
from quantlib.cashflow cimport Leg

cdef class OvernightIndexedCoupon(FloatingRateCoupon):
    pass

cdef class OvernightLeg(Leg):
    pass

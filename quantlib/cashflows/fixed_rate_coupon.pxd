from quantlib.cashflows.coupon cimport Coupon
from quantlib.cashflow cimport Leg
cimport quantlib.cashflows._fixed_rate_coupon as _frc

cdef class FixedRateCoupon(Coupon):
    pass

cdef class FixedRateLeg(Leg):
    cdef _frc.FixedRateLeg* frl

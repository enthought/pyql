from quantlib.cashflows.coupon cimport Coupon
from . cimport _floating_rate_coupon as _frc

cdef class FloatingRateCoupon(Coupon):
    cdef inline _frc.FloatingRateCoupon* _get_frc(self)

from .floating_rate_coupon cimport FloatingRateCoupon
from quantlib.cashflow cimport Leg
from . cimport _overnight_indexed_coupon as _oic

cdef class OvernightIndexedCoupon(FloatingRateCoupon):
    pass

cdef class OvernightLeg(Leg):
    cdef _oic.OvernightLeg* leg

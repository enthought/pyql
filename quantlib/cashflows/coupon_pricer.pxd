from quantlib.handle cimport shared_ptr
from . cimport _coupon_pricer as _cp

cdef class FloatingRateCouponPricer:
    cdef shared_ptr[_cp.FloatingRateCouponPricer] _thisptr

cdef class IborCouponPricer(FloatingRateCouponPricer):
    pass

cdef class CmsCouponPricer(FloatingRateCouponPricer):
    pass

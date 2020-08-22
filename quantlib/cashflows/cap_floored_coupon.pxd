from .floating_rate_coupon cimport FloatingRateCoupon
from . cimport _cap_floored_coupon as _cfc

cdef class CappedFlooredCoupon(FloatingRateCoupon):
    cdef inline _cfc.CappedFlooredCoupon* as_ptr(self)

cdef class CappedFlooredIborCoupon(CappedFlooredCoupon):
    pass

cdef class CappedFlooredCmsCoupon(CappedFlooredCoupon):
    pass

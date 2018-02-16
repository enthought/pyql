from floating_rate_coupon cimport FloatingRateCoupon

cdef class CappedFlooredCoupon(FloatingRateCoupon):
    pass

cdef class CappedFlooredIborCoupon(CappedFlooredCoupon):
    pass

cdef class CappedFlooredCmsCoupon(CappedFlooredCoupon):
    pass

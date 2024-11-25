from .coupon_pricer cimport FloatingRateCouponPricer

cdef class CompoundingOvernightIndexedCouponPricer(FloatingRateCouponPricer):
     pass


cdef class ArithmeticAveragedOvernightIndexedCouponPricer(FloatingRateCouponPricer):
    pass

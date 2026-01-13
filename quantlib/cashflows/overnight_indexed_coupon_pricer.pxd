from .coupon_pricer cimport FloatingRateCouponPricer

cdef class OvernightIndexedCouponPricer(FloatingRateCouponPricer):
    pass

cdef class CompoundingOvernightIndexedCouponPricer(OvernightIndexedCouponPricer):
     pass


cdef class ArithmeticAveragedOvernightIndexedCouponPricer(OvernightIndexedCouponPricer):
    pass

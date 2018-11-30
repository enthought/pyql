from .coupon_pricer cimport CmsCouponPricer

cdef class HaganPricer(CmsCouponPricer):
    pass

cdef class AnalyticHaganPricer(CmsCouponPricer):
    pass

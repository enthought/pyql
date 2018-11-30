from .coupon_pricer cimport CmsCouponPricer
from ._linear_tsr_pricer cimport LinearTsrPricer as QlLinearTsrPricer

cdef class Settings:
    cdef QlLinearTsrPricer.Settings _thisptr

cdef class LinearTsrPricer(CmsCouponPricer):
    pass

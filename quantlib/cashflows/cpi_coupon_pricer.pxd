from . cimport _cpi_coupon_pricer as _cpi
from .inflation_coupon_pricer cimport InflationCouponPricer

cdef class CPICouponPricer(InflationCouponPricer):
    pass

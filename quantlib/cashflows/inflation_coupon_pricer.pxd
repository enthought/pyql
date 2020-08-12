from quantlib.handle cimport shared_ptr
from . cimport _inflation_coupon_pricer as _icp

cdef class InflationCouponPricer:
    cdef shared_ptr[_icp.InflationCouponPricer] _thisptr

cdef class YoYInflationCouponPricer(InflationCouponPricer):
    pass

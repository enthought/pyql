cimport _cms_spread_coupon as _csc
from quantlib.cashflows.floating_rate_coupon cimport FloatingRateCoupon
from quantlib.cashflows.coupon_pricer cimport FloatingRateCouponPricer

cdef class CmsSpreadCoupon(FloatingRateCoupon):
    pass

cdef class CmsSpreadCouponPricer(FloatingRateCouponPricer):
    pass

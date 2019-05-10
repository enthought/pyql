from quantlib.cashflows.floating_rate_coupon cimport FloatingRateCoupon
from quantlib.cashflows.coupon_pricer cimport FloatingRateCouponPricer
from quantlib.cashflows.cap_floored_coupon cimport CappedFlooredCoupon

cdef class CmsSpreadCoupon(FloatingRateCoupon):
    pass

cdef class CappedFlooredCmsSpreadCoupon(CappedFlooredCoupon):
    pass

cdef class CmsSpreadCouponPricer(FloatingRateCouponPricer):
    pass

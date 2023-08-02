include '../../types.pxi'

from quantlib.handle cimport Handle, optional, shared_ptr, static_pointer_cast

from .cms_spread_coupon cimport CmsSpreadCouponPricer
from quantlib.cashflows.coupon_pricer cimport CmsCouponPricer
from quantlib.quote cimport Quote
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.termstructures.volatility.volatilitytype cimport VolatilityType
from quantlib.utilities.null cimport Null
cimport quantlib.cashflows._coupon_pricer as _cp
from . cimport _lognormal_cmsspread_pricer as _lcp

cdef class LognormalCmsSpreadPricer(CmsSpreadCouponPricer):
    def __init__(self, CmsCouponPricer cms_pricer not None,
                 Quote correlation not None,
                 YieldTermStructure coupon_discount_curve=YieldTermStructure(),
                 Size integration_points=16,
                 vol_type=None,
                 Real shift1=Null[Real](),
                 Real shift2=Null[Real]()):
        cdef optional[VolatilityType] vol_type_option
        if vol_type is not None:
            vol_type_option = <VolatilityType>vol_type

        self._thisptr = shared_ptr[_cp.FloatingRateCouponPricer](
            new _lcp.LognormalCmsSpreadPricer(
                static_pointer_cast[_cp.CmsCouponPricer](cms_pricer._thisptr),
                correlation.handle(),
                coupon_discount_curve._thisptr,
                integration_points,
                vol_type_option,
                shift1,
                shift2
            )
        )

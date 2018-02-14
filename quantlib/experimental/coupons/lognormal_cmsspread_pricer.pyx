include '../../types.pxi'

from quantlib.handle cimport Handle, optional, shared_ptr, static_pointer_cast

from cms_spread_coupon cimport CmsSpreadCouponPricer
from quantlib.cashflows.coupon_pricer cimport CmsCouponPricer
from quantlib.quotes cimport SimpleQuote
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.termstructures.volatility.volatilitytype cimport VolatilityType
from quantlib.defines cimport QL_NULL_REAL
cimport quantlib.cashflows._coupon_pricer as _cp
cimport quantlib._quote as _qt
cimport _lognormal_cmsspread_pricer as _lcp

cdef class LognormalCmsSpreadPricer(CmsSpreadCouponPricer):
    def __init__(self, CmsCouponPricer cms_pricer,
                 SimpleQuote correlation not None,
                 YieldTermStructure coupon_discount_curve not None,
                 Size integration_points=16,
                 VolatilityType vol_type=None,
                 Real shift1=QL_NULL_REAL,
                 Real shift2=QL_NULL_REAL):
        cdef Handle[_qt.Quote] correlation_handle = \
            Handle[_qt.Quote](correlation._thisptr)
        cdef optional[VolatilityType] vol_type_option
        if vol_type is not None:
            vol_type_option = vol_type

        self._thisptr = shared_ptr[_cp.FloatingRateCouponPricer](
            new _lcp.LognormalCmsSpreadPricer(
                static_pointer_cast[_cp.CmsCouponPricer](cms_pricer._thisptr),
                correlation_handle,
                coupon_discount_curve._thisptr,
                integration_points,
                vol_type_option,
                shift1,
                shift2
            )
        )

include '../../types.pxi'
from libcpp.string cimport string
from quantlib.handle cimport shared_ptr, Handle, optional
from _cms_spread_coupon cimport CmsSpreadCouponPricer
from quantlib.cashflows._coupon_pricer cimport CmsCouponPricer
from quantlib._quote cimport Quote
from quantlib.termstructures.volatility.volatilitytype cimport VolatilityType
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/experimental/coupons/lognormalcmsspreadpricer.hpp' namespace 'QuantLib':
    cdef cppclass LognormalCmsSpreadPricer(CmsSpreadCouponPricer):
        LognormalCmsSpreadPricer(
            const shared_ptr[CmsCouponPricer] cmsPricer,
            const Handle[Quote] &correlation,
            const Handle[YieldTermStructure] &couponDiscountCurve, # = Handle[YieldTermStructure]()
            const Size IntegrationPoints, # = 16,
            const optional[VolatilityType] volatilityType, # = boost::none,
            const Real shift1, # = Null<Real>
            const Real shift2) # = Null<Real>

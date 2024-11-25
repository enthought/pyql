from quantlib.types cimport Real
from libcpp cimport bool
from . cimport _overnight_indexed_coupon_pricer as _oicp

cdef class CompoundingOvernightIndexedCouponPricer(FloatingRateCouponPricer):
     def __init__(self):
         self._thisptr.reset(new _oicp.CompoundingOvernightIndexedCouponPricer())

cdef class ArithmeticAveragedOvernightIndexedCouponPricer(FloatingRateCouponPricer):
    def __init__(self, Real mean_reversion = 0.03, Real volatility=0.0, bool by_approx=False):
        """ pricer for arithmetically averaged overnight indexed coupons

        Reference: Katsumi Takada 2011, Valuation of Arithmetically Average of
        Fed Funds Rates and Construction of the US Dollar Swap Yield Curve"""

        self._thisptr.reset(new _oicp.ArithmeticAveragedOvernightIndexedCouponPricer(mean_reversion, volatility, by_approx))

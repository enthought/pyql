include '../types.pxi'

from . cimport _coupon_pricer as _cp
cimport quantlib.termstructures.volatility.swaption._swaption_vol_structure as _svs
from quantlib.termstructures.volatility.swaption.swaption_vol_structure \
    cimport SwaptionVolatilityStructure
from quantlib.handle cimport Handle, shared_ptr, static_pointer_cast
from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from quantlib.quote cimport Quote

cdef class LinearTsrPricer(CmsCouponPricer):
    def __init__(self, swaption_vol not None,
                 Quote mean_reversion not None,
                 HandleYieldTermStructure coupon_discount_curve=HandleYieldTermStructure(),
                 Settings settings=Settings()):

        self._thisptr = shared_ptr[_cp.FloatingRateCouponPricer](
                new QlLinearTsrPricer(
            SwaptionVolatilityStructure.swaption_vol_handle(swaption_vol),
            mean_reversion.handle(),
            coupon_discount_curve.handle,
            settings._thisptr
        ))

cdef class Settings:
    def with_rate_bound(self, Real lower_rate_bound=0.0001,
            Real upper_rate_bound=2.0000):
        self._thisptr.withRateBound(lower_rate_bound,
                upper_rate_bound)
        return self

    def with_vega_ratio(self, Real vega_ratio=0.01,
            lower_rate_bound=None, upper_rate_bound=None):
        if lower_rate_bound is not None and upper_rate_bound is not None:
            self._thisptr.withVegaRatio(vega_ratio, <Real?>lower_rate_bound,
                    <Real?>upper_rate_bound)
        else:
            self._thisptr.withVegaRatio(vega_ratio)
        return self

    def with_price_threshold(self, Real price_threshold=1e-8):
        self._thisptr.withPriceThreshold(price_threshold)
        return self

    def with_bs_std_devs(self, Real std_devs):
        self._thisptr.withBSStdDevs(std_devs)
        return self

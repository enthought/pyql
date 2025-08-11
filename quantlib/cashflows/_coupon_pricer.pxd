from quantlib.types cimport Rate, Real

from quantlib.handle cimport shared_ptr, Handle
from quantlib.termstructures.volatility.optionlet._optionlet_volatility_structure cimport OptionletVolatilityStructure
from quantlib.termstructures.volatility.swaption._swaption_vol_structure cimport SwaptionVolatilityStructure
from quantlib._cashflow cimport Leg
from quantlib.cashflows._floating_rate_coupon cimport FloatingRateCoupon
from quantlib._quote cimport Quote

cdef extern from 'ql/cashflows/couponpricer.hpp' namespace 'QuantLib' nogil:

    cdef cppclass FloatingRateCouponPricer:
        FloatingRateCouponPricer() except +
        Real swapletPrice() except +
        Rate swapletRate() except +
        Real capletPrice(Rate effectiveCap) except +
        Rate capletRate(Rate effectiveCap) except +
        Real floorletPrice(Rate effectiveFloor) except +
        Rate floorletRate(Rate effectiveFloor) except +
        void initialize(const FloatingRateCoupon& coupon)

    cdef cppclass IborCouponPricer(FloatingRateCouponPricer):
        IborCouponPricer() except +
        IborCouponPricer(
            const Handle[OptionletVolatilityStructure]& v) except +

    cdef cppclass BlackIborCouponPricer(IborCouponPricer):
        BlackIborCouponPricer() except +
        BlackIborCouponPricer(
            Handle[OptionletVolatilityStructure]& v,
            TimingAdjustment timing_adjustment,
            const Handle[Quote] correlation) except +

    void setCouponPricer(Leg& leg, shared_ptr[FloatingRateCouponPricer]& pricer) except +

    cdef cppclass CmsCouponPricer(FloatingRateCouponPricer):
        CmsCouponPricer()
        CmsCouponPricer(const Handle[SwaptionVolatilityStructure]& v) except +
        Handle[SwaptionVolatilityStructure] swaptionVolatility()
        void setSwaptionVolatility(const Handle[SwaptionVolatilityStructure]& v)

cdef extern from 'ql/cashflows/couponpricer.hpp' namespace 'QuantLib::BlackIborCouponPricer':
    cdef enum TimingAdjustment:
        Black76
        BivariateLognormal

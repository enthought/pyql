from libcpp cimport bool
from quantlib.types cimport Rate
from cython.operator cimport dereference as deref
from quantlib.cashflow cimport Leg
cimport quantlib.termstructures.volatility.swaption._swaption_vol_structure  as _svs
from quantlib.ext cimport static_pointer_cast, optional
from quantlib.handle cimport Handle, HandleSwaptionVolatilityStructure, HandleOptionletVolatilityStructure
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.quote cimport Quote
from quantlib.quotes.simplequote cimport SimpleQuote
from .coupon_pricer cimport FloatingRateCouponPricer
from .floating_rate_coupon cimport FloatingRateCoupon
from . cimport _floating_rate_coupon as _frc
cimport quantlib._cashflow as _cf

cdef class FloatingRateCouponPricer:

    def __cinit__(self):
        if type(self) in (FloatingRateCouponPricer, IborCouponPricer):
            raise ValueError(f"'{type(self).__name__}' cannot be directly instantiated!")

    def initialize(self, FloatingRateCoupon coupon not None):
        self._thisptr.get().initialize(deref(<_frc.FloatingRateCoupon*>coupon._thisptr.get()))

    def swaplet_price(self):
        return self._thisptr.get().swapletPrice()

    def swaplet_rate(self):
        return self._thisptr.get().swapletRate()

    def caplet_price(self, Rate effective_cap):
        return self._thisptr.get().capletPrice(effective_cap)

    def caplet_rate(self, Rate effective_cap):
        return self._thisptr.get().capletRate(effective_cap)

    def floorlet_price(self, Rate effective_floor):
        return self._thisptr.get().floorletPrice(effective_floor)

    def floorlet_rate(self, Rate effective_floor):
        return self._thisptr.get().floorletRate(effective_floor)


cpdef enum TimingAdjustment:
    Black76 = _cp.Black76
    BivariateLognormal = _cp.BivariateLognormal

cdef class BlackIborCouponPricer(IborCouponPricer):

    def __init__(self,
                 HandleOptionletVolatilityStructure ovs=HandleOptionletVolatilityStructure(),
                 TimingAdjustment timing_adjustment=Black76,
                 Quote correlation=SimpleQuote(1.),
                 use_indexed_coupon=None):
        cdef optional[bool] indexed_coupon
        if use_indexed_coupon is not None:
            indexed_coupon = <bool>use_indexed_coupon
        self._thisptr.reset(
            new _cp.BlackIborCouponPricer(
                ovs.handle(),
                timing_adjustment,
                correlation.handle(),
                indexed_coupon,
            )
        )

def set_coupon_pricer(Leg leg, FloatingRateCouponPricer pricer):
    """sets the coupon pricer

    Parameters
    ----------
    leg : Leg
    pricer : FloatingRateCouponPricer
    """
    _cp.setCouponPricer(leg._thisptr, pricer._thisptr)

cdef class CmsCouponPricer(FloatingRateCouponPricer):

    @property
    def swaption_volatility(self):
        cdef HandleSwaptionVolatilityStructure instance = (
            HandleSwaptionVolatilityStructure.__new__(HandleSwaptionVolatilityStructure)
        )
        instance._handle = new Handle[_svs.SwaptionVolatilityStructure](
            (<_cp.CmsCouponPricer*>self._thisptr.get()).swaptionVolatility()
        )
        return instance

    @swaption_volatility.setter
    def swaption_volatility(self, HandleSwaptionVolatilityStructure v not None):
        (<_cp.CmsCouponPricer*>self._thisptr.get()).setSwaptionVolatility(v.handle())

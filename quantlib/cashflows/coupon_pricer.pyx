include '../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.cashflow cimport Leg
from quantlib.termstructures.volatility.optionlet.optionlet_volatility_structure cimport OptionletVolatilityStructure
cimport quantlib.termstructures.volatility.optionlet._optionlet_volatility_structure as _ovs
from quantlib.termstructures.volatility.swaption.swaption_vol_structure \
    cimport  SwaptionVolatilityStructure
from quantlib.termstructures._vol_term_structure cimport VolatilityTermStructure
cimport quantlib.termstructures.volatility.swaption._swaption_vol_structure  as _svs
from quantlib.handle cimport Handle, static_pointer_cast
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.quote cimport Quote
from quantlib.quotes.simplequote cimport SimpleQuote
from .coupon_pricer cimport FloatingRateCouponPricer
cimport quantlib._cashflow as _cf

cdef class FloatingRateCouponPricer:

    def __init__(self):
        raise ValueError(
            'CouponPricer cannot be directly instantiated!'
        )

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


cdef class IborCouponPricer(FloatingRateCouponPricer):

    def __init__(self):
        raise ValueError(
            'IborCouponPricer cannot be directly instantiated!'
        )


cpdef enum TimingAdjustment:
    Black76 = _cp.Black76
    BivariateLognormal = _cp.BivariateLognormal

cdef class BlackIborCouponPricer(IborCouponPricer):

    def __init__(self,
                 OptionletVolatilityStructure ovs=OptionletVolatilityStructure(),
                 TimingAdjustment timing_adjustment=Black76,
                 Quote correlation=SimpleQuote(1.)):
        cdef Handle[_ovs.OptionletVolatilityStructure] ovs_handle = \
            Handle[_ovs.OptionletVolatilityStructure](ovs._thisptr)
        self._thisptr = shared_ptr[_cp.FloatingRateCouponPricer](
            new _cp.BlackIborCouponPricer(
                ovs_handle,
                timing_adjustment,
                correlation.handle()
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
        cdef Handle[_svs.SwaptionVolatilityStructure] vol_handle = \
        (<_cp.CmsCouponPricer*>self._thisptr.get()).swaptionVolatility()
        cdef SwaptionVolatilityStructure instance = (SwaptionVolatilityStructure.
                                                     __new__(SwaptionVolatilityStructure))
        if not vol_handle.empty():
            instance._thisptr = vol_handle.currentLink()
        return instance

    @swaption_volatility.setter
    def swaption_volatility(self, v not None):
        (<_cp.CmsCouponPricer*>self._thisptr.get()).setSwaptionVolatility(SwaptionVolatilityStructure.swaption_vol_handle(v))

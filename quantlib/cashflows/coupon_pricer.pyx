include '../types.pxi'

from cython.operator cimport dereference as deref
cimport _coupon_pricer as _cp
cimport quantlib.instruments._bonds as _bonds
from quantlib.termstructures.volatility.optionlet.optionlet_volatility_structure cimport OptionletVolatilityStructure
cimport quantlib.termstructures.volatility.optionlet._optionlet_volatility_structure as _ovs
from quantlib.termstructures.volatility.swaption.swaption_vol_structure \
    cimport  SwaptionVolatilityStructure
cimport quantlib.termstructures.volatility.swaption._swaption_vol_structure  as _svs
from quantlib.handle cimport Handle
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.quotes cimport SimpleQuote
from coupon_pricer cimport FloatingRateCouponPricer
from quantlib.instruments.bonds cimport Bond
cimport quantlib._cashflow as _cf
cimport quantlib._quote as _qt

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
                 SimpleQuote correlation=SimpleQuote(1.)):
        cdef Handle[_ovs.OptionletVolatilityStructure] ovs_handle = \
            Handle[_ovs.OptionletVolatilityStructure](ovs._thisptr)
        cdef Handle[_qt.Quote] correlation_handle = Handle[_qt.Quote](correlation._thisptr)
        self._thisptr = shared_ptr[_cp.FloatingRateCouponPricer](
            new _cp.BlackIborCouponPricer(
                ovs_handle,
                timing_adjustment,
                correlation_handle
            )
        )

def set_coupon_pricer(Bond frb, FloatingRateCouponPricer pricer):
    """ Parameters :
        ----------
        1) frb : FloatingRateBond
            Bond object to be used to extract cashflows
        2) pricer : FloatingRateCouponPricer
            BlackIborCouponPricer has been exposed"""
    bond_leg = (<_bonds.Bond*>frb._thisptr.get()).cashflows()
    _cp.setCouponPricer(bond_leg, pricer._thisptr)

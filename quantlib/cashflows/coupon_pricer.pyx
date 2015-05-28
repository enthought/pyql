from cython.operator cimport dereference as deref
cimport _coupon_pricer as _cp
cimport quantlib.instruments._bonds as _bonds
from quantlib.termstructures.volatility.optionlet.optionlet_volatility_structure cimport OptionletVolatilityStructure
cimport quantlib.termstructures.volatility.optionlet._optionlet_volatility_structure as _ovs
from quantlib.handle cimport Handle
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from coupon_pricer cimport FloatingRateCouponPricer
from quantlib.cashflow cimport Leg
from quantlib.instruments.bonds cimport Bond
cimport quantlib._cashflow as _cf
cdef class IborCouponPricer:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    def __init__(self):
        raise ValueError(
            'IborCouponPricer cannot be directly instantiated!'
        )
    #def setCapletVolatility(self, OptionletVolatilityStructure olvs): 
    #    ovs_handle = new Handle[_ovs.OptionletVolatilityStructure](deref(olvs._thisptr))
    #   self._thisptr.get().setCapletVolatility(ovs_handle)

cdef class BlackIborCouponPricer(IborCouponPricer):

    def __init__(self,
        OptionletVolatilityStructure ovs
    ):
        ovs_handle = new Handle[_ovs.OptionletVolatilityStructure](deref(ovs._thisptr))
        self._thisptr = new shared_ptr[_cp.FloatingRateCouponPricer](
            new _cp.BlackIborCouponPricer(
                deref(ovs_handle)
            )
        )

def set_coupon_pricer(Bond frb, pricer):
    """ Parameters :
        ----------
        1) frb : FloatingRateBond  
            Bond object to be used to extract cashflows
        2) pricer : FloatingRateCouponPricer 
            BlackIborCouponPricer has been exposed"""
    cdef shared_ptr[_cp.FloatingRateCouponPricer] pricer_sp
    pricer_sp = deref((<FloatingRateCouponPricer>pricer)._thisptr)
    bond_leg = (<_bonds.Bond*>frb._thisptr.get()).cashflows()
    _cp.setCouponPricer(bond_leg, pricer_sp)
    
    
include '../types.pxi'

from quantlib.handle cimport shared_ptr, Handle
from quantlib.termstructures.volatility.optionlet._optionlet_volatility_structure cimport OptionletVolatilityStructure
from quantlib._cashflow cimport Leg
cdef extern from 'ql/cashflows/couponpricer.hpp' namespace 'QuantLib':

    cdef cppclass FloatingRateCouponPricer:
        FloatingRateCouponPricer()
        Real swapletPrice()
        Rate swapletRate()
        Real capletPrice(Rate effectiveCap)
        Rate capletRate(Rate effectiveCap)
        Real floorletPrice(Rate effectiveFloor)
        Rate floorletRate(Rate effectiveFloor)
        
    cdef cppclass IborCouponPricer(FloatingRateCouponPricer):
        IborCouponPricer()
        IborCouponPricer(
            Handle[OptionletVolatilityStructure]& v)
        #void setCapletVolatility(
        #    Handle[OptionletVolatilityStructure]& ovs)
    
    cdef cppclass BlackIborCouponPricer(IborCouponPricer):
        BlackIborCouponPricer()
        BlackIborCouponPricer(
            Handle[OptionletVolatilityStructure]& v)

    void setCouponPricer(Leg& leg, shared_ptr[FloatingRateCouponPricer]& pricer)
include '../types.pxi'

from quantlib.handle cimport shared_ptr, Handle
from quantlib.termstructures.volatility.optionlet._optionlet_volatility_structure cimport OptionletVolatilityStructure
from quantlib._cashflow cimport Leg
cdef extern from 'ql/cashflows/couponpricer.hpp' namespace 'QuantLib':

    cdef cppclass FloatingRateCouponPricer:
        FloatingRateCouponPricer() except +
        Real swapletPrice() except +
        Rate swapletRate() except +
        Real capletPrice(Rate effectiveCap) except +
        Rate capletRate(Rate effectiveCap) except +
        Real floorletPrice(Rate effectiveFloor) except +
        Rate floorletRate(Rate effectiveFloor) except +
        
    cdef cppclass IborCouponPricer(FloatingRateCouponPricer):
        IborCouponPricer() except +
        IborCouponPricer(
            Handle[OptionletVolatilityStructure]& v) except +
    
    cdef cppclass BlackIborCouponPricer(IborCouponPricer):
        BlackIborCouponPricer() except +
        BlackIborCouponPricer(
            Handle[OptionletVolatilityStructure]& v) except +

    void setCouponPricer(Leg& leg, shared_ptr[FloatingRateCouponPricer]& pricer) except +
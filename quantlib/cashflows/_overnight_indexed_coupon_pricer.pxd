from quantlib.types cimport Rate, Real
from libcpp cimport bool
from quantlib.handle cimport Handle
from ._coupon_pricer cimport FloatingRateCouponPricer
from quantlib.termstructures.volatility.optionlet._optionlet_volatility_structure cimport OptionletVolatilityStructure

cdef extern from 'ql/cashflows/overnightindexedcouponpricer.hpp' namespace 'QuantLib' nogil:

    cdef cppclass OvernightIndexedCouponPricer(FloatingRateCouponPricer):
        pass

    cdef cppclass CompoundingOvernightIndexedCouponPricer(OvernightIndexedCouponPricer):
        pass
    cdef cppclass ArithmeticAveragedOvernightIndexedCouponPricer(OvernightIndexedCouponPricer):
        ArithmeticAveragedOvernightIndexedCouponPricer(
            Real meanReversion, # = 0.03
            Real volatility, # = 0.00 No convexity adjustment by default
            bool byApprox, # = false, True to use Katsumi Takada approximation
            Handle[OptionletVolatilityStructure] v, # = Handle[OptionletVolatilityStructure]()
            const bool effective_volatility_input, # = False
        )

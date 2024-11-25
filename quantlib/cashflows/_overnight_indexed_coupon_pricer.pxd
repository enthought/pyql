from quantlib.types cimport Rate, Real
from libcpp cimport bool
from ._coupon_pricer cimport FloatingRateCouponPricer

cdef extern from 'ql/cashflows/overnightindexedcouponpricer.hpp' namespace 'QuantLib' nogil:
    cdef cppclass CompoundingOvernightIndexedCouponPricer(FloatingRateCouponPricer):
        pass
    cdef cppclass ArithmeticAveragedOvernightIndexedCouponPricer(FloatingRateCouponPricer):
        ArithmeticAveragedOvernightIndexedCouponPricer(
            Real meanReversion, # = 0.03
            Real volatility, # = 0.00 No convexity adjustment by default
            bool byApprox # = false, True to use Katsumi Takada approximation
        )

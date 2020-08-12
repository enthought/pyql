from quantlib.handle cimport shared_ptr
from ._inflation_coupon_pricer cimport InflationCouponPricer as QlInflationCouponPricer
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure

cdef class CPICouponPricer(InflationCouponPricer):
    def __init__(self, YieldTermStructure nominal_ts):
        self._thisptr = shared_ptr[QlInflationCouponPricer](
            new _cpi.CPICouponPricer(nominal_ts._thisptr)
        )

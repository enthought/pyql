from ._inflation_coupon_pricer cimport InflationCouponPricer as QlInflationCouponPricer
from quantlib.handle cimport HandleYieldTermStructure

cdef class CPICouponPricer(InflationCouponPricer):
    def __init__(self, HandleYieldTermStructure nominal_ts):
        self._thisptr.reset(
            new _cpi.CPICouponPricer(nominal_ts.handle())
        )

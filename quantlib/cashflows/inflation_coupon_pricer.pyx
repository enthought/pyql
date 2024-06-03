from quantlib.cashflow cimport Leg
from .inflation_coupon_pricer cimport InflationCouponPricer
from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure

cdef class InflationCouponPricer:
    pass

cdef class YoYInflationCouponPricer(InflationCouponPricer):
    def __init__(self, HandleYieldTermStructure nominal_ts):
        self._thisptr = shared_ptr[_icp.InflationCouponPricer](
            new _icp.YoYInflationCouponPricer(nominal_ts.handle)
        )

def set_coupon_pricer(Leg leg, InflationCouponPricer pricer):
    """ Parameters
        ----------
        leg : Leg object
        pricer : InflationCouponPricer"""
    _icp.setCouponPricer(leg._thisptr, pricer._thisptr)

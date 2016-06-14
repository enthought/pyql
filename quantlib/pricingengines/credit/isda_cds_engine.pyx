from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.handle cimport shared_ptr, Handle, optional

from quantlib.pricingengines.engine cimport PricingEngine

cimport quantlib.pricingengines._pricing_engine as _pe
cimport _isda_cds_engine as _ice

cimport quantlib.termstructures._default_term_structure as _dts
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.termstructures.default_term_structure cimport DefaultProbabilityTermStructure
from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure

cpdef enum NumericalFix:
    No = _ice.No
    Taylor = _ice.Taylor

cpdef enum AccrualBias:
    HalfDayBias = _ice.HalfDayBias
    NoBias = _ice.NoBias

cpdef enum ForwardsInCouponPeriod:
    Flat = _ice.Flat
    Piecewise = _ice.Piecewise

cdef class IsdaCdsEngine(PricingEngine):

    def __init__(self, DefaultProbabilityTermStructure ts, double recovery_rate,
                 YieldTermStructure discount_curve, bool include_settlement_date_flows = None,
                 _ice.NumericalFix numerical_fix = NumericalFix.Taylor,
                 _ice.AccrualBias accrual_bias = AccrualBias.NoBias,
                 _ice.ForwardsInCouponPeriod forwards_in_coupon_period = ForwardsInCouponPeriod.Piecewise):
        """
        First argument should be a DefaultProbabilityTermStructure. Using
        the PiecewiseDefaultCurve at the moment.

        """


        cdef Handle[_dts.DefaultProbabilityTermStructure] handle = \
            Handle[_dts.DefaultProbabilityTermStructure](<shared_ptr[_dts.DefaultProbabilityTermStructure]>
                                                         ts._thisptr)

        cdef Handle[_yts.YieldTermStructure] yts_handle = \
            deref(discount_curve._thisptr.get())
        cdef optional[bool] settlement_flows
        if include_settlement_date_flows is None:
            settlement_flows = optional[bool]()
        else:
             settlement_flows = optional[bool](include_settlement_date_flows)
        self._thisptr = shared_ptr[_pe.PricingEngine](
            new _ice.IsdaCdsEngine(handle, recovery_rate, yts_handle,
                                   settlement_flows, _ice.Taylor,
                                   _ice.NoBias, _ice.Piecewise)
            )

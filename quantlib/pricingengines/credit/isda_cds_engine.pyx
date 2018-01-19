from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.handle cimport shared_ptr, Handle, optional, make_optional    

from quantlib.pricingengines.engine cimport PricingEngine

cimport quantlib.pricingengines._pricing_engine as _pe
cimport _isda_cds_engine as _ice

cimport quantlib.termstructures._default_term_structure as _dts
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.termstructures.default_term_structure cimport DefaultProbabilityTermStructure
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.termstructures.yields.rate_helpers cimport RateHelper
from quantlib.termstructures.credit.default_probability_helpers cimport CdsHelper

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

    def __init__(self, ts, double recovery_rate, discount_curve,
                 bool include_settlement_date_flows=None,
                 _ice.NumericalFix numerical_fix=NumericalFix.Taylor,
                 _ice.AccrualBias accrual_bias=AccrualBias.HalfDayBias,
                 _ice.ForwardsInCouponPeriod forwards_in_coupon_period=ForwardsInCouponPeriod.Piecewise):
        """
        First argument should be a DefaultProbabilityTermStructure.

        """

        cdef optional[bool] settlement_flows = make_optional[bool](
                include_settlement_date_flows is not None,
                include_settlement_date_flows)
        cdef Handle[_dts.DefaultProbabilityTermStructure] handle
        cdef vector[shared_ptr[_ice.DefaultProbabilityHelper]] cds_helpers
        cdef vector[shared_ptr[_ice.RateHelper]] rate_helpers

        if isinstance(ts, DefaultProbabilityTermStructure) and \
           isinstance(discount_curve, YieldTermStructure):
            handle = Handle[_dts.DefaultProbabilityTermStructure](
                (<DefaultProbabilityTermStructure>ts)._thisptr)

            self._thisptr = new shared_ptr[_pe.PricingEngine](
                new _ice.IsdaCdsEngine(handle, recovery_rate,
                                       (<YieldTermStructure>discount_curve)._thisptr,
                                       settlement_flows, numerical_fix,
                                       accrual_bias, forwards_in_coupon_period)
            )
        elif isinstance(ts, list) and isinstance(discount_curve, list):
            for cds_helper in ts:
                cds_helpers.push_back(
                    <shared_ptr[_ice.DefaultProbabilityHelper]>
                        deref((<CdsHelper?>cds_helper)._thisptr))
            for rate_helper in discount_curve:
                rate_helpers.push_back((<RateHelper?>rate_helper)._thisptr)
            self._thisptr = new shared_ptr[_pe.PricingEngine](
                new _ice.IsdaCdsEngine(cds_helpers, recovery_rate, rate_helpers,
                                       settlement_flows, numerical_fix,
                                       accrual_bias, forwards_in_coupon_period))

        else:
            raise ValueError('ts and discount_curve need to be both a list of helpers or a TermStructure')

    cdef _ice.IsdaCdsEngine* _get_cds_engine(self):
        cdef _ice.IsdaCdsEngine* ref = <_ice.IsdaCdsEngine*>(self._thisptr.get())
        return ref

    @property
    def isda_rate_curve(self):
        cdef YieldTermStructure yts = YieldTermStructure()
        yts._thisptr.linkTo(self._get_cds_engine().isdaRateCurve().currentLink())
        return yts

    @property
    def isda_credit_curve(self):
        cdef DefaultProbabilityTermStructure dts = DefaultProbabilityTermStructure()
        dts._thisptr = self._get_cds_engine().isdaCreditCurve().currentLink()
        return dts

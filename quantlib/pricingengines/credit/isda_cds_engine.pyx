from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.handle cimport shared_ptr, Handle, optional

from quantlib.pricingengines.engine cimport PricingEngine

cimport quantlib.pricingengines._pricing_engine as _pe
from . cimport _isda_cds_engine as _ice

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

    def __init__(self, DefaultProbabilityTermStructure ts not None,
                 double recovery_rate,
                 YieldTermStructure discount_curve not None,
                 include_settlement_date_flows=None,
                 NumericalFix numerical_fix=NumericalFix.Taylor,
                 AccrualBias accrual_bias=AccrualBias.HalfDayBias,
                 ForwardsInCouponPeriod forwards_in_coupon_period=ForwardsInCouponPeriod.Piecewise):
        """
        constructor where client code is responsible for providing a default curve
        and an interest curve compliant with the ISDA specifications.
        """

        cdef optional[bool] settlement_flows
        if include_settlement_date_flows is not None:
            settlement_flows = <bool>include_settlement_date_flows

        cdef Handle[_dts.DefaultProbabilityTermStructure] handle = \
            Handle[_dts.DefaultProbabilityTermStructure](ts._thisptr)

        self._thisptr.reset(
            new _ice.IsdaCdsEngine(handle, recovery_rate,
                                   discount_curve._thisptr,
                                   settlement_flows,
                                   <_ice.NumericalFix>numerical_fix,
                                   <_ice.AccrualBias>accrual_bias,
                                   <_ice.ForwardsInCouponPeriod>forwards_in_coupon_period)
        )

    cdef inline _ice.IsdaCdsEngine* _get_cds_engine(self) nogil:
        return <_ice.IsdaCdsEngine*>(self._thisptr.get())

    @property
    def isda_rate_curve(self):
        cdef YieldTermStructure yts = YieldTermStructure.__new__(YieldTermStructure)
        yts._thisptr.linkTo(self._get_cds_engine().isdaRateCurve().currentLink())
        return yts

    @property
    def isda_credit_curve(self):
        cdef DefaultProbabilityTermStructure dts = DefaultProbabilityTermStructure.__new__(DefaultProbabilityTermStructure)
        dts._thisptr = self._get_cds_engine().isdaCreditCurve().currentLink()
        return dts

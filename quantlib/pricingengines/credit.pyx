"""
 Copyright (C) 2011, Enthought Inc

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from cython.operator cimport dereference as deref
from libcpp cimport bool

from quantlib.handle cimport Handle, shared_ptr, optional
cimport _pricing_engine as _pe
cimport _credit

from engine cimport PricingEngine

cimport quantlib.termstructures._default_term_structure as _dts
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.termstructures.default_term_structure cimport DefaultProbabilityTermStructure
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure

cdef class MidPointCdsEngine(PricingEngine):

    def __init__(self, DefaultProbabilityTermStructure ts, double recovery_rate,
                 YieldTermStructure discount_curve, include_settlement_date_flows=None):
        """
        First argument should be a DefaultProbabilityTermStructure. Using
        the PiecewiseDefaultCurve at the moment.

        """

        cdef Handle[_dts.DefaultProbabilityTermStructure] handle = \
            Handle[_dts.DefaultProbabilityTermStructure](ts._thisptr)
        cdef optional[bool] c_include_settlement_date_flows
        if include_settlement_date_flows is not None:
            c_include_settlement_date_flows = <bool>include_settlement_date_flows
        self._thisptr = new shared_ptr[_pe.PricingEngine](
            new _credit.MidPointCdsEngine(handle, recovery_rate, discount_curve._thisptr,
                                          c_include_settlement_date_flows)
        )

cdef class IsdaCdsEngine(PricingEngine):

    def __init__(self, DefaultProbabilityTermStructure ts, double recovery_rate,
                 YieldTermStructure discount_curve, bool include_settlement_date_flows = None,
                 _credit.NumericalFix numerical_fix = _credit.Taylor,
                 _credit.AccrualBias accrual_bias = _credit.NoBias,
                 _credit.ForwardsInCouponPeriod forwards_in_coupon_period = _credit.Piecewise):
        """
        First argument should be a DefaultProbabilityTermStructure. Using
        the PiecewiseDefaultCurve at the moment.

        """


        cdef Handle[_dts.DefaultProbabilityTermStructure] handle = \
            Handle[_dts.DefaultProbabilityTermStructure](deref(ts._thisptr))

        cdef optional[bool] settlement_flows = make_option[bool](
                include_settlement_date_flows is not None,
                include_settlement_date_flows)

        self._thisptr = shared_ptr[_pe.PricingEngine](
            new _credit.IsdaCdsEngine(handle, recovery_rate, discount_curve._thisptr,
                                      settlement_flows, _credit.Taylor,
                                      _credit.NoBias, _credit.Piecewise)
            )

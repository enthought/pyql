"""
 Copyright (C) 2011, Enthought Inc

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from cython.operator cimport dereference as deref
from libcpp cimport bool

from quantlib.handle cimport optional
from . cimport _midpoint_cds_engine as _mce

from quantlib.pricingengines.engine cimport PricingEngine

cimport quantlib.termstructures._default_term_structure as _dts
from quantlib.termstructures.default_term_structure cimport HandleDefaultProbabilityTermStructure
from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure


cdef class MidPointCdsEngine(PricingEngine):

    def __init__(self, HandleDefaultProbabilityTermStructure ts not None, double recovery_rate,
                 HandleYieldTermStructure discount_curve not None,
                 include_settlement_date_flows=None):
        """
        First argument should be a DefaultProbabilityTermStructure. Using
        the PiecewiseDefaultCurve at the moment.


        """

        cdef optional[bool] include_settlement_date_flows_opt
        if include_settlement_date_flows is not None:
            include_settlement_date_flows_opt = <bool>include_settlement_date_flows
        self._thisptr.reset(
            new _mce.MidPointCdsEngine(ts.handle, recovery_rate, discount_curve.handle,
                include_settlement_date_flows_opt,
                )
        )

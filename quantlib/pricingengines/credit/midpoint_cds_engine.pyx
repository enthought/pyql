"""
 Copyright (C) 2011, Enthought Inc

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from cython.operator cimport dereference as deref
from libcpp cimport bool

from quantlib.handle cimport Handle, shared_ptr, make_optional
cimport quantlib.pricingengines._pricing_engine as _pe
cimport _midpoint_cds_engine as _mce

from quantlib.pricingengines.engine cimport PricingEngine

cimport quantlib.termstructures._default_term_structure as _dts
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.termstructures.default_term_structure cimport DefaultProbabilityTermStructure
from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure


cdef class MidPointCdsEngine(PricingEngine):

    def __init__(self, DefaultProbabilityTermStructure ts not None, double recovery_rate,
                 YieldTermStructure discount_curve not None,
                 bool include_settlement_date_flows=None):
        """
        First argument should be a DefaultProbabilityTermStructure. Using
        the PiecewiseDefaultCurve at the moment.


        """

        cdef Handle[_dts.DefaultProbabilityTermStructure] handle = \
            Handle[_dts.DefaultProbabilityTermStructure](ts._thisptr)

        self._thisptr = new shared_ptr[_pe.PricingEngine](
            new _mce.MidPointCdsEngine(handle, recovery_rate, discount_curve._thisptr,
                                       make_optional[bool](
                                           include_settlement_date_flows is not None,
                                           include_settlement_date_flows))
        )

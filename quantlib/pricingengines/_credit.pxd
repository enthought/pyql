
include '../types.pxi'
from libcpp cimport bool

from quantlib.handle cimport Handle, optional
from quantlib.termstructures._default_term_structure cimport DefaultProbabilityTermStructure
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from _pricing_engine cimport PricingEngine

cdef extern from 'ql/pricingengines/credit/midpointcdsengine.hpp' namespace 'QuantLib':

    cdef cppclass MidPointCdsEngine(PricingEngine):
        MidPointCdsEngine(
              Handle[DefaultProbabilityTermStructure]&,
              Real recoveryRate,
              Handle[YieldTermStructure]& discountCurve,
              optional[bool] includeSettlementDateFlows
        )



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

cdef extern from 'ql/pricingengines/credit/isdacdsengine.hpp' namespace 'QuantLib':

    cdef cppclass IsdaCdsEngine(PricingEngine):
        IsdaCdsEngine(
            Handle[DefaultProbabilityTermStructure]&,
            Real recoveryRate,
            Handle[YieldTermStructure]& discountCurve,
            optional[bool] includeSettlementDateFlows,
            NumericalFix,
            AccrualBias,
            ForwardsInCouponPeriod
        )

cdef extern from 'ql/pricingengines/credit/isdacdsengine.hpp' namespace 'QuantLib::IsdaCdsEngine':

    cdef enum NumericalFix:
        No "QuantLib::IsdaCdsEngine::None"
        Taylor

    cdef enum AccrualBias:
        HalfDayBias
        NoBias

    cdef enum ForwardsInCouponPeriod:
        Flat
        Piecewise

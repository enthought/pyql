include '../../types.pxi'
from libcpp cimport bool
from libcpp.vector cimport vector

from quantlib.handle cimport Handle, optional, shared_ptr
from quantlib.termstructures._default_term_structure cimport DefaultProbabilityTermStructure
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.pricingengines._pricing_engine cimport PricingEngine
from quantlib.termstructures.credit._credit_helpers cimport DefaultProbabilityHelper, CdsHelper
from quantlib.termstructures.yields._rate_helpers cimport RateHelper

cdef extern from 'ql/pricingengines/credit/isdacdsengine.hpp' namespace 'QuantLib':

    cdef cppclass IsdaCdsEngine(PricingEngine):
        IsdaCdsEngine(
            Handle[DefaultProbabilityTermStructure]&,
            Real recoveryRate,
            Handle[YieldTermStructure]& discountCurve,
            optional[bool] includeSettlementDateFlows, # = none
            NumericalFix, # = Taylor
            AccrualBias, # = NoBias
            ForwardsInCouponPeriod # = Piecewise
        )
        IsdaCdsEngine(
            const vector[shared_ptr[DefaultProbabilityHelper]] & probabilityHelpers,
            Real recoveryRate,
            const vector[shared_ptr[RateHelper]] & rateHelpers,
            optional[bool] includeSettlementDateFlows, # = none
            const NumericalFix numericalFix, # = Taylor
            const AccrualBias accrualBias, # = NoBias
            const ForwardsInCouponPeriod) # = Piecewise
        const Handle[YieldTermStructure]& isdaRateCurve()
        const Handle[DefaultProbabilityTermStructure]& isdaCreditCurve()
        void calculate()

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

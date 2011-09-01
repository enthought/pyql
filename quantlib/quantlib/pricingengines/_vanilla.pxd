from quantlib.handle cimport shared_ptr
from quantlib.processes._black_scholes_process cimport GeneralizedBlackScholesProcess

cdef extern from 'ql/pricingengine.hpp' namespace 'QuantLib':

    cdef cppclass PricingEngine:
        PricingEngine()

cdef extern from 'ql/pricingengines/vanilla/analyticeuropeanengine.hpp' namespace 'QuantLib':

    cdef cppclass AnalyticEuropeanEngine(PricingEngine):
        AnalyticEuropeanEngine(
            shared_ptr[GeneralizedBlackScholesProcess]& process
        )

cdef extern from 'ql/pricingengines/vanilla/baroneadesiwhaleyengine.hpp' namespace 'QuantLib':

    cdef cppclass BaroneAdesiWhaleyApproximationEngine(PricingEngine):
        BaroneAdesiWhaleyApproximationEngine(
            shared_ptr[GeneralizedBlackScholesProcess]& process
        )


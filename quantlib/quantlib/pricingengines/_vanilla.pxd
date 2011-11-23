include '../types.pxi'

from quantlib.handle cimport shared_ptr
from quantlib.processes._black_scholes_process cimport GeneralizedBlackScholesProcess
from quantlib.models.equity._heston_model cimport HestonModel

from _pricing_engine cimport PricingEngine

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

cdef extern from 'ql/pricingengines/vanilla/analytichestonengine.hpp' namespace 'QuantLib':

    cdef cppclass AnalyticHestonEngine(PricingEngine):
        AnalyticHestonEngine(
            shared_ptr[HestonModel]& model,
            Size integrationOrder
        )


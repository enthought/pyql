include '../types.pxi'

from quantlib.handle cimport shared_ptr
from quantlib.processes._black_scholes_process cimport GeneralizedBlackScholesProcess
from quantlib.models.equity._heston_model cimport HestonModel
from quantlib.models.equity._bates_model cimport (BatesModel, BatesDetJumpModel, BatesDoubleExpModel, BatesDoubleExpDetJumpModel)

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
        AnalyticHestonEngine()
        AnalyticHestonEngine(
            shared_ptr[HestonModel]& model,
            Size integrationOrder
        )

cdef extern from 'ql/pricingengines/vanilla/batesengine.hpp' namespace 'QuantLib':

    cdef cppclass BatesEngine(AnalyticHestonEngine):
        BatesEngine()
        BatesEngine(
            shared_ptr[BatesModel]& model,
            Size integrationOrder
        )

    cdef cppclass BatesDetJumpEngine(BatesEngine):
        BatesDetJumpEngine()
        BatesDetJumpEngine(
            shared_ptr[BatesDetJumpModel]& model,
            Size integrationOrder
        )
        BatesDetJumpEngine(
            shared_ptr[BatesDetJumpModel]& model,
            Real relTolerance,
            Size integrationOrder
        )

    cdef cppclass BatesDoubleExpEngine(AnalyticHestonEngine):
        BatesDoubleExpEngine()
        BatesDoubleExpEngine(
            shared_ptr[BatesDoubleExpModel]& model,
            Size integrationOrder
        )
        BatesDoubleExpEngine(
            shared_ptr[BatesDoubleExpModel]& model,
            Real relTolerance,
            Size integrationOrder
        )

    cdef cppclass BatesDoubleExpDetJumpEngine(BatesDoubleExpEngine):
        BatesDoubleExpDetJumpEngine()
        BatesDoubleExpDetJumpEngine(
            shared_ptr[BatesDoubleExpDetJumpModel]& model,
            Size integrationOrder
        )
        BatesDoubleExpDetJumpEngine(
            shared_ptr[BatesDoubleExpDetJumpModel]& model,
            Real relTolerance,
            Size integrationOrder
        )

cdef extern from 'ql/pricingengines/vanilla/analyticdividendeuropeanengine.hpp' namespace 'QuantLib':

    cdef cppclass AnalyticDividendEuropeanEngine(PricingEngine):
        AnalyticDividendEuropeanEngine(
            shared_ptr[GeneralizedBlackScholesProcess]& process
        )
        void calculate()

cdef extern from 'ql/pricingengines/vanilla/fddividendamericanengine.hpp' namespace 'QuantLib':
    cdef cppclass FDDividendAmericanEngine[T]:
        FDDividendAmericanEngine(
            shared_ptr[GeneralizedBlackScholesProcess]& process,
            Size timesteps,
            Size gridpoints,

        )
        FDDividendAmericanEngine(
            shared_ptr[GeneralizedBlackScholesProcess]& process,
            Size timesteps,
            Size gridpoints,
            timedependent
        )
cdef extern from 'ql/pricingengines/vanilla/fdamericanengine.hpp' namespace 'QuantLib':
    cdef cppclass FDAmericanEngine[T]:
        FDAmericanEngine(
             shared_ptr[GeneralizedBlackScholesProcess]& process,
             Size timeSteps,
             Size gridPoints,
             #bool timeDependent = false
        )


cdef extern from 'ql/methods/finitedifferences/cranknicolson.hpp' namespace 'QuantLib':

    cdef cppclass CrankNicolson:
        pass


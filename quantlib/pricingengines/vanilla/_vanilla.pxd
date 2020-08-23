include '../../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector

from quantlib.handle cimport shared_ptr
from quantlib.processes._black_scholes_process cimport GeneralizedBlackScholesProcess
from quantlib.models.shortrate.onefactormodels._hullwhite cimport HullWhite
from quantlib.processes._hullwhite_process cimport HullWhiteProcess
from quantlib.models.equity._heston_model cimport HestonModel
from quantlib.models.equity._bates_model cimport (BatesModel, BatesDetJumpModel, BatesDoubleExpModel, BatesDoubleExpDetJumpModel)

from quantlib.pricingengines._pricing_engine cimport PricingEngine
cimport quantlib.methods.finitedifferences.solvers._fdmbackwardsolver as _fdm

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


cdef extern from 'ql/pricingengines/vanilla/analyticbsmhullwhiteengine.hpp' namespace 'QuantLib':

    cdef cppclass AnalyticBSMHullWhiteEngine(PricingEngine):
        AnalyticBSMHullWhiteEngine()
        AnalyticBSMHullWhiteEngine(
            Real equity_short_rate_correlation,
            shared_ptr[GeneralizedBlackScholesProcess]& process,
            shared_ptr[HullWhite]& hw_model)

cdef extern from 'ql/pricingengines/vanilla/analytichestonhullwhiteengine.hpp' namespace 'QuantLib':

    cdef cppclass AnalyticHestonHullWhiteEngine(PricingEngine):
        AnalyticHestonHullWhiteEngine()
        AnalyticHestonHullWhiteEngine(
            shared_ptr[HestonModel]& heston_model,
            shared_ptr[HullWhite]& hw_model,
            Size integrationOrder
        )

cdef extern from 'ql/pricingengines/vanilla/fdhestonhullwhitevanillaengine.hpp' namespace 'QuantLib':

    cdef cppclass FdHestonHullWhiteVanillaEngine(PricingEngine):
        FdHestonHullWhiteVanillaEngine()
        FdHestonHullWhiteVanillaEngine(
            shared_ptr[HestonModel]& heston_model,
            shared_ptr[HullWhiteProcess]& hw_process,
            Real corrEquityShortRate,
            Size tGrid, Size xGrid,
            Size vGrid, Size rGrid,
            Size dampingSteps,
            bool controlVariate,
            _fdm.FdmSchemeDesc& schemeDesc)

        void enableMultipleStrikesCaching(vector[double]&)


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

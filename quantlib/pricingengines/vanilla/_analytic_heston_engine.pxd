from quantlib.types cimport Real, Size
from quantlib.handle cimport shared_ptr
from quantlib.models.equity._heston_model cimport HestonModel
from quantlib.pricingengines._pricing_engine cimport PricingEngine

cdef extern from 'ql/pricingengines/vanilla/analytichestonengine.hpp' namespace 'QuantLib'  nogil:
    cdef cppclass AnalyticHestonEngine(PricingEngine):
        cppclass Integration:
            Integration(Integration&)
            @staticmethod
            Integration gaussLaguerre(Size integrationOrder)# = 128)

            @staticmethod
            Integration gaussLegendre(Size integrationOrder)# = 128)

            @staticmethod
            Integration gaussChebyshev(Size integrationOrder)# = 128)

            @staticmethod
            Integration gaussChebyshev2nd(Size integrationOrder)# = 128)

            @staticmethod
            Integration gaussLobatto(Real relTolerance, Real absTolerance,
                                     Size maxEvaluations)# = 1000)

        enum ComplexLogFormula:
            pass
        # Simple to use constructor: Using adaptive
        # Gauss-Lobatto integration and Gatheral's version of complex log.
        # Be aware: using a too large number for maxEvaluations might result
        # in a stack overflow as the Lobatto integration is a recursive
        # algorithm.
        AnalyticHestonEngine(const shared_ptr[HestonModel]& model,
                             Real relTolerance, Size maxEvaluations)

        # Constructor using Laguerre integration
        # and Gatheral's version of complex log.
        AnalyticHestonEngine(const shared_ptr[HestonModel]& model,
                             Size integrationOrder) # = 144)

        # Constructor giving full control
        # over the Fourier integration algorithm
        AnalyticHestonEngine(const shared_ptr[HestonModel]& model,
                             ComplexLogFormula cpxLog, const Integration& itg,
                             Real andersenPiterbargEpsilon) # = 1e-8)
        Size numberOfEvaluations()

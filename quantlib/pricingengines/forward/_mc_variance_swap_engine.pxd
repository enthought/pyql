include '../../types.pxi'

from libcpp cimport bool

from quantlib.handle cimport shared_ptr
from quantlib.pricingengines._pricing_engine cimport PricingEngine
from quantlib.processes._black_scholes_process cimport GeneralizedBlackScholesProcess


cdef extern from 'ql/pricingengines/forward/mcvarianceswapengine.hpp' namespace 'QuantLib':

    cdef cppclass MCVarianceSwapEngine[RNG=*, S=*](PricingEngine):
        MCVarianceSwapEngine(
             shared_ptr[GeneralizedBlackScholesProcess]& process,
             Size timeSteps,
             Size timeStepsPerYear,
             bool brownianBridge,
             bool antitheticVariate,
             Size requiredSamples,
             Real requiredTolerance,
             Size maxSamples,
             BigNatural seed) except +

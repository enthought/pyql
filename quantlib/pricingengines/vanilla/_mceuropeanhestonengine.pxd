from quantlib.types cimport BigNatural, Real, Size
from libcpp cimport bool
from quantlib.processes._heston_process cimport HestonProcess
from quantlib.pricingengines._pricing_engine cimport PricingEngine
from quantlib.handle cimport shared_ptr
from ._mcvanillaengine cimport MCVanillaEngine
from quantlib.methods.montecarlo._mctraits cimport MultiVariate

#needed to prevent a Forward declaration error
cdef extern from 'ql/exercise.hpp':
    pass

cdef extern from 'ql/pricingengines/vanilla/mceuropeanhestonengine.hpp' namespace 'QuantLib' nogil:
    cdef cppclass MCEuropeanHestonEngine[RNG=*,S=*,P=*](MCVanillaEngine[MultiVariate, RNG, S]):
        MCEuropeanHestonEngine(shared_ptr[HestonProcess]& sp,
                               Size timeSteps,
                               Size timeStepsPerYear,
                               bool antitheticVariate,
                               Size requiredSamples,
                               Real requiredTolerance,
                               Size maxSamples,
                               BigNatural seed) except +

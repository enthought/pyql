from quantlib.types cimport BigNatural, Real, Size
from libcpp cimport bool
from quantlib.processes._hybrid_heston_hullwhite_process cimport HybridHestonHullWhiteProcess
from quantlib.pricingengines._pricing_engine cimport PricingEngine
from quantlib.handle cimport shared_ptr
from ._mcvanillaengine cimport MCVanillaEngine
from quantlib.methods.montecarlo._mctraits cimport MultiVariate

cdef extern from 'ql/pricingengines/vanilla/mchestonhullwhiteengine.hpp' namespace 'QuantLib' nogil:
    cdef cppclass MCHestonHullWhiteEngine[RNG=*,S=*](MCVanillaEngine[MultiVariate, RNG, S]):
        MCHestonHullWhiteEngine(shared_ptr[HybridHestonHullWhiteProcess]& sp,
                                Size timeSteps,
                                Size timeStepsPerYear,
                                bool antitheticVariate,
                                bool controlVariate,
                                Size requiredSamples,
                                Real requiredTolerance,
                                Size maxSamples,
                                BigNatural seed) except +
    cdef cppclass MakeMCHestonHullWhiteEngine[RNG=*,S=*]:
        MakeMCHestonHullWhiteEngine(shared_ptr[HybridHestonHullWhiteProcess])
        MakeMCHestonHullWhiteEngine& withSteps(Size steps)
        MakeMCHestonHullWhiteEngine& withStepsPerYear(Size steps)
        MakeMCHestonHullWhiteEngine& withAntitheticVariate(bool b = true)
        MakeMCHestonHullWhiteEngine& withControlVariate(bool b = true)
        MakeMCHestonHullWhiteEngine& withSamples(Size samples)
        MakeMCHestonHullWhiteEngine& withAbsoluteTolerance(Real tolerance)
        MakeMCHestonHullWhiteEngine& withMaxSamples(Size samples)
        MakeMCHestonHullWhiteEngine& withSeed(BigNatural seed)
        # conversion to pricing engine
        shared_ptr[PricingEngine] operator() const

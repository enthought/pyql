from quantlib.pricingengines.engine cimport PricingEngine

from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess

from .analytic_heston_engine cimport AnalyticHestonEngine

cdef class VanillaOptionEngine(PricingEngine):
    cdef GeneralizedBlackScholesProcess process

cdef class AnalyticEuropeanEngine(VanillaOptionEngine):
    pass

cdef class BaroneAdesiWhaleyApproximationEngine(VanillaOptionEngine):
    pass

cdef class AnalyticBSMHullWhiteEngine(PricingEngine):
    pass

cdef class AnalyticHestonHullWhiteEngine(PricingEngine):
    pass

cdef class FdHestonHullWhiteVanillaEngine(PricingEngine):
    pass

cdef class BatesEngine(AnalyticHestonEngine):
    pass

cdef class BatesDetJumpEngine(BatesEngine):
    pass

cdef class BatesDoubleExpEngine(AnalyticHestonEngine):
    pass

cdef class BatesDoubleExpDetJumpEngine(BatesDoubleExpEngine):
    pass

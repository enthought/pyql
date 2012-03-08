cimport _vanilla

from quantlib.handle cimport shared_ptr
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess

cdef class PricingEngine:
    cdef shared_ptr[_vanilla.PricingEngine]* _thisptr

cdef class VanillaOptionEngine(PricingEngine):
    cdef GeneralizedBlackScholesProcess process

cdef class AnalyticEuropeanEngine(VanillaOptionEngine):
    pass

cdef class BaroneAdesiWhaleyApproximationEngine(VanillaOptionEngine):
    pass

cdef class AnalyticHestonEngine(PricingEngine):
    pass

cdef class BatesEngine(AnalyticHestonEngine):
    pass

cdef class BatesDetJumpEngine(BatesEngine):
    pass

cdef class BatesDoubleExpEngine(AnalyticHestonEngine):
    pass

cdef class BatesDoubleExpDetJumpEngine(BatesDoubleExpEngine):
    pass

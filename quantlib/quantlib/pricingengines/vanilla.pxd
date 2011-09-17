cimport _vanilla

from quantlib.handle cimport shared_ptr
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess

cdef class VanillaOptionEngine:
    cdef _vanilla.PricingEngine* _thisptr
    cdef GeneralizedBlackScholesProcess process

cdef class AnalyticEuropeanEngine(VanillaOptionEngine):
    pass

cdef class BaroneAdesiWhaleyApproximationEngine(VanillaOptionEngine):
    pass


cdef class AnalyticHestonEngine:
    cdef shared_ptr[_vanilla.AnalyticHestonEngine]* _thisptr

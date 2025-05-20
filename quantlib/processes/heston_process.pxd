from quantlib.stochastic_process cimport StochasticProcess
from ._heston_process cimport HestonProcess as QlHestonProcess

cdef extern from "ql/processes/hestonprocess.hpp" namespace "QuantLib::HestonProcess" nogil:
    cpdef enum Discretization:
        PartialTruncation
        FullTruncation
        Reflection
        NonCentralChiSquareVariance
        QuadraticExponential
        QuadraticExponentialMartingale
        BroadieKayaExactSchemeLobatto
        BroadieKayaExactSchemeLaguerre
        BroadieKayaExactSchemeTrapezoidal

cdef class HestonProcess(StochasticProcess):
    pass

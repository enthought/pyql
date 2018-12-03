from quantlib.stochastic_process cimport StochasticProcess
from ._heston_process cimport HestonProcess as QlHestonProcess

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

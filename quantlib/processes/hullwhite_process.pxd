from quantlib.stochastic_process cimport StochasticProcess1D
from .forwardmeasureprocess cimport ForwardMeasureProcess1D

cdef class HullWhiteProcess(StochasticProcess1D):
    pass

cdef class HullWhiteForwardProcess(ForwardMeasureProcess1D):
    pass

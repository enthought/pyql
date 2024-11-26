from quantlib.types cimport Time
from .._stochastic_process cimport StochasticProcess, StochasticProcess1D

cdef extern from 'ql/processes/forwardmeasureprocess.hpp' namespace 'QuantLib' nogil:
    cdef cppclass ForwardMeasureProcess(StochasticProcess):
        void setForwardMeasureTime(Time)
        Time getForwardMeasureTime() const

    cdef cppclass ForwardMeasureProcess1D(StochasticProcess1D):
        void setForwardMeasureTime(Time)
        Time getForwardMeasureTime() const

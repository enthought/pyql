from quantlib.types cimport Real
from quantlib.handle cimport shared_ptr
from quantlib._stochastic_process cimport StochasticProcess
from ._heston_process cimport HestonProcess
from ._hullwhite_process cimport HullWhiteForwardProcess

cdef extern from 'ql/processes/hybridhestonhullwhiteprocess.hpp' namespace 'QuantLib' nogil:

    cdef cppclass HybridHestonHullWhiteProcess(StochasticProcess):
        enum Discretization:
            Euler
            BSMHullWhite
        HybridHestonHullWhiteProcess(
            shared_ptr[HestonProcess]& heston_process,
            shared_ptr[HullWhiteForwardProcess]& hullWhiteProcess,
            Real corrEquityShortRate,
            HybridHestonHullWhiteProcess.Discretization discretization) # = BSMHullWhite

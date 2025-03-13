from quantlib.stochastic_process cimport StochasticProcess

cdef extern from "ql/processes/hybridhestonhullwhiteprocess.hpp" namespace "QuantLib::HybridHestonHullWhiteProcess" nogil:
    cpdef enum class Discretization:
        Euler
        BSMHullWhite

cdef class HybridHestonHullWhiteProcess(StochasticProcess):
    pass

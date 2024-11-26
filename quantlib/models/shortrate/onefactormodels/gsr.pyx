from quantlib.types cimport Real
from libcpp.vector cimport vector
from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure

cdef class Gsr(Gaussian1dModel):
    def __init__(self, HandleYieldTermStructure h, vol_step_date, vector[Real] volatilities, Real reversion, Real T=60.0):
        pass

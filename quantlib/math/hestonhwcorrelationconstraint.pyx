include '../types.pxi'

from quantlib.handle cimport shared_ptr
from quantlib.math.optimization cimport Constraint
cimport _optimization as _opt

import numpy as np
cimport numpy as cnp

cdef extern from "constraint_support_code.hpp" namespace 'PyQL':

    cdef cppclass HestonHullWhiteCorrelationConstraint(_opt.Constraint):
        HestonHullWhiteCorrelationConstraint(Real corr)

        
cdef class HestonHWCorrelationConstraint(Constraint):

    def __init__(self, double equity_short_rate_corr):

        self._thisptr = new shared_ptr[_opt.Constraint](
            new HestonHullWhiteCorrelationConstraint(
                equity_short_rate_corr))

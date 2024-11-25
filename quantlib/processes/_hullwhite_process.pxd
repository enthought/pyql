"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from quantlib.types cimport Real

from quantlib.handle cimport Handle
from quantlib.termstructures.yields._flat_forward cimport YieldTermStructure
from quantlib._stochastic_process cimport StochasticProcess1D

cdef extern from 'ql/processes/hullwhiteprocess.hpp' namespace 'QuantLib' nogil:

    cdef cppclass HullWhiteProcess(StochasticProcess1D):
        HullWhiteProcess(
            Handle[YieldTermStructure]& riskFreeRate,
            Real a, Real sigma) except +

        Real a()
        Real sigma()

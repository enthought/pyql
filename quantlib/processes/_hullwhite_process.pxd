#
# Copyright (C) 2015, Enthought Inc
# Copyright (C) 2015, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

from quantlib.types cimport Real, Time

from quantlib.handle cimport Handle
from quantlib.termstructures.yields._flat_forward cimport YieldTermStructure
from quantlib._stochastic_process cimport StochasticProcess1D
from ._forwardmeasureprocess cimport ForwardMeasureProcess1D

cdef extern from 'ql/processes/hullwhiteprocess.hpp' namespace 'QuantLib' nogil:

    cdef cppclass HullWhiteProcess(StochasticProcess1D):
        HullWhiteProcess(
            Handle[YieldTermStructure]& riskFreeRate,
            Real a, Real sigma) except +

        Real a() const
        Real sigma() const
        Real alpha(Time t) const

    cdef cppclass HullWhiteForwardProcess(ForwardMeasureProcess1D):
        HullWhiteForwardProcess(
            Handle[YieldTermStructure]& riskFreeRate,
            Real a, Real sigma) except +

        Real a() const
        Real sigma() const
        Real alpha(Time t) const
        Real M_T(Real s, Real t, Real T) const
        Real B(Time t, Time T) const

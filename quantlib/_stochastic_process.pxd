# Copyright (C) 2012, Enthought Inc
# Copyright (C) 2012, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

from quantlib.types cimport Real, Size, Time

cdef extern from 'ql/stochasticprocess.hpp' namespace 'QuantLib' nogil:

    cdef cppclass StochasticProcess:
        Size size()
        Size factors()

    cdef cppclass StochasticProcess1D(StochasticProcess) nogil:
        Real x0()
        Real drift(Time t, Real x)
        Real diffusion(Time t, Real x)
        Real expectation(Time t0, Real x0, Time dt)
        Real stdDeviation(Time t0, Real x0, Time dt)
        Real variance(Time t0, Real x0, Time dt)

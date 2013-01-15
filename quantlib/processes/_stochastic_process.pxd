"""
 Copyright (C) 2012, Enthought Inc
 Copyright (C) 2012, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

cdef extern from 'ql/stochasticprocess.hpp' namespace 'QuantLib':

    cdef cppclass StochasticProcess1D:
        StochasticProcess1D()

    cdef cppclass StochasticProcess:
        StochasticProcess()

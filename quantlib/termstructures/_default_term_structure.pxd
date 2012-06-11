"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from libcpp cimport bool

cdef extern from 'ql/termstructures/defaulttermstructure.hpp' namespace 'QuantLib':

    cdef cppclass DefaultProbabilityTermStructure:
        DefaultProbabilityTermStructure()

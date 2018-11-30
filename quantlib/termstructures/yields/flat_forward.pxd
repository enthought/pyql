"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from libcpp cimport bool as cbool
from quantlib.handle cimport shared_ptr

from quantlib.termstructures.yield_term_structure cimport YieldTermStructure

cdef class FlatForward(YieldTermStructure):
    pass



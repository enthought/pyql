"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

cimport quantlib.math._optimization as _opt
from quantlib.handle cimport shared_ptr

cdef extern from "constraint_support_code.hpp" namespace "QuantLib":
    cdef shared_ptr[_opt.Constraint] constraint_factory(Real x) except +


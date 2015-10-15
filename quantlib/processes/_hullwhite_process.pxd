"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from quantlib.handle cimport Handle, shared_ptr
from quantlib.termstructures.yields._flat_forward cimport YieldTermStructure

cdef extern from 'ql/processes/hullwhiteprocess.hpp' namespace 'QuantLib':

    cdef cppclass HullWhiteProcess:
        HullWhiteProcess()
        HullWhiteProcess(
            Handle[YieldTermStructure]& riskFreeRate,
            Real a, Real sigma) except +
            
        Real a() except +
        Real sigma() except +

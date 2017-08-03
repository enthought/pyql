"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

cdef extern from 'ql/math/array.hpp' namespace 'QuantLib':
    cdef cppclass Array:
        Array()
        Array(size_t size)
        Array(size_t size, double value)
        Real& at(Size i) except +IndexError
        Size size()
        Real& operator[](Size)

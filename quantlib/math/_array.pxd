"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

cdef extern from 'ql/math/array.hpp' namespace 'QuantLib':
    cdef cppclass Array:
        Array()
        Array(size_t size)
        Array(size_t size, double value)
        double at(size_t i) except +
        size_t size() except +

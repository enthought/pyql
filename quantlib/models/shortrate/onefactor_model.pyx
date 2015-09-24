"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

cdef class OneFactorAffineModel:

    def __cinit__(self):
        pass

    def __init__(self):
        raise ValueError('Cannot instantiate OneFactorAffineModel')

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

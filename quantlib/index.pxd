"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

cimport quantlib._index as _in
from quantlib.handle cimport shared_ptr

cdef class Index:
    cdef shared_ptr[_in.Index] _thisptr

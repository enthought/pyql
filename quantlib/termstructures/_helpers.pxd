"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from quantlib.handle cimport Handle
from quantlib._quote cimport Quote


cdef extern from 'ql/termstructures/bootstraphelper.hpp' namespace 'QuantLib':

    cdef cppclass BootstrapHelper[T]:
        BootstrapHelper() # added a fake constructor for Cython
        BootstrapHelper(Handle[Quote]& quote)
        BootstrapHelper(Real quote)
        Handle[Quote] quote()

    # Faking the typedef because not supported by Cython 0.15
    cdef cppclass RelativeDateBootstrapHelper[T](BootstrapHelper):
        pass

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
from quantlib.time._date cimport Date

cdef extern from 'ql/termstructures/bootstraphelper.hpp' namespace 'QuantLib':

    cdef cppclass BootstrapHelper[T]:
        BootstrapHelper() # added a fake constructor for Cython
        BootstrapHelper(Handle[Quote]& quote)
        BootstrapHelper(Real quote)
        Handle[Quote] quote()
        Real impliedQuote() except +
        Date maturityDate() except +
        Date latestDate() except +
        void update()

    cdef cppclass RelativeDateBootstrapHelper[T](BootstrapHelper):
        pass

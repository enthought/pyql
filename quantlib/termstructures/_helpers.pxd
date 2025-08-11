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

cdef extern from 'ql/termstructures/bootstraphelper.hpp' namespace 'QuantLib' nogil:
    cdef cppclass BootstrapHelper[T]:
        BootstrapHelper(Handle[Quote]& quote)
        BootstrapHelper(Real quote)
        Handle[Quote] quote()
        Real impliedQuote() except +
        Date earliestDate() except +
        Date maturityDate() except +
        Date latestDate() except +
        void update()
        void setTermStructure(T*)

    cdef cppclass RelativeDateBootstrapHelper[T](BootstrapHelper):
        pass

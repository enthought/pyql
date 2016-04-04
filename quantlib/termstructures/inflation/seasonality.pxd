"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

cimport _seasonality as _se
from quantlib.handle cimport shared_ptr

cdef class Seasonality:
    cdef shared_ptr[_se.Seasonality]* _thisptr

cdef class MultiplicativePriceSeasonality(Seasonality):
    pass

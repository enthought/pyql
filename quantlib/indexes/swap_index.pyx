"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'
from cython.operator cimport dereference as deref

from quantlib.index cimport Index
from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Period
from quantlib.time.daycounter cimport DayCounter
from quantlib.currency cimport Currency
from quantlib.time.calendar cimport Calendar

cimport quantlib._index as _in
cimport quantlib.indexes._swap_index as _si

cdef extern from "string" namespace "std":
    cdef cppclass string:
        char* c_str()

cdef class SwapIndex(Index):

    def __str__(self):
        return 'Swap index %s' % self.name

    def __init__(self, family_name, tenor, settlement_days, currency, calendar, fixed_leg_tenor,
                 fixed_leg_convention, fixed_leg_daycounter, ibor_index):
        pass

"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'
from cython.operator cimport dereference as deref
from libcpp.string cimport string

from quantlib.index cimport Index
from quantlib.indexes.ibor_index cimport IborIndex
from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Period
from quantlib.time.daycounter cimport DayCounter
from quantlib.currency.currency cimport Currency
from quantlib.time.date cimport Date
from quantlib.time.calendar cimport Calendar
from quantlib.time._calendar cimport BusinessDayConvention

cimport quantlib._index as _in
cimport _swap_index as _si
cimport _ibor_index as _ii

cdef class SwapIndex(Index):

    def __str__(self):
        return 'Swap index %s' % self.name

    def __init__(self, family_name, Period tenor not None, Natural settlement_days,
                 Currency currency, Calendar calendar not None,
                 Period fixed_leg_tenor not None,
                 int fixed_leg_convention, DayCounter fixed_leg_daycounter not None,
                 IborIndex ibor_index not None):

        # convert the Python str to C++ string
        cdef string family_name_string = family_name.encode('utf-8')

        self._thisptr = new shared_ptr[_in.Index](
            new _si.SwapIndex(
                family_name_string,
                deref(tenor._thisptr),
                <Natural> settlement_days,
                deref(currency._thisptr),
                deref(calendar._thisptr),
                deref(fixed_leg_tenor._thisptr),
                <BusinessDayConvention> fixed_leg_convention,
                deref(fixed_leg_daycounter._thisptr),
                deref(<shared_ptr[_ii.IborIndex]*> ibor_index._thisptr)
            )
        )

    def underlying_swap(self, Date fixing_date):
        pass

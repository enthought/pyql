"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'

from cython.operator cimport dereference as deref

cimport _rate_helpers as _rh
from quantlib.handle cimport shared_ptr, Handle
cimport quantlib._quote as _qt
cimport quantlib.indexes._ibor_index as _ib
from quantlib.quotes cimport Quote
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Period
from quantlib.time._period cimport Frequency
from quantlib.time._calendar cimport BusinessDayConvention
from quantlib.indexes.ibor_index cimport IborIndex

from quantlib.time.calendar import ModifiedFollowing

cdef class RateHelper:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            print 'Deallocting RateHelper'
            del self._thisptr

cdef class RelativeDateRateHelper:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            print 'Deallocting RelativeDateRateHelper'
            del self._thisptr

cdef class DepositRateHelper(RateHelper):

    def __init__(self, Rate quote, Period tenor, Natural fixing_days,
        Calendar calendar, int convention=ModifiedFollowing,
        end_of_month=True, DayCounter deposit_day_counter=None
    ):

        self._thisptr = new shared_ptr[_rh.RateHelper](
            new _rh.DepositRateHelper(
                quote,
                deref(tenor._thisptr.get()),
                <int>fixing_days,
                deref(calendar._thisptr),
                <_rh.BusinessDayConvention>convention,
                True,
                deref(deposit_day_counter._thisptr)
            )
        )

    property quote:
        def __get__(self):
            cdef Handle[_qt.Quote] quote_handle = self._thisptr.get().quote()
            cdef shared_ptr[_qt.Quote] quote_ptr = shared_ptr[_qt.Quote](quote_handle.currentLink())
            value = quote_ptr.get().value()
            return value

cdef class SwapRateHelper(RelativeDateRateHelper):

    def __init__(self, Quote rate, Period tenor, 
        Calendar calendar, Frequency fixedFrequency,
        BusinessDayConvention fixedConvention, DayCounter fixedDayCount,
        IborIndex iborIndex, Quote spread, Period fwdStart):

        cdef Handle[_qt.Quote] rate_handle = Handle[_qt.Quote](deref(rate._thisptr))
        cdef Handle[_qt.Quote] spread_handle = Handle[_qt.Quote](deref(spread._thisptr))

        self._thisptr = new shared_ptr[_rh.RelativeDateRateHelper](
            new _rh.SwapRateHelper(
                rate_handle,
                deref(tenor._thisptr.get()),
                deref(calendar._thisptr),
                <Frequency> fixedFrequency,
                <_rh.BusinessDayConvention> fixedConvention,
                deref(fixedDayCount._thisptr),
                deref(<shared_ptr[_ib.IborIndex]*> iborIndex._thisptr),
                spread_handle,
                deref(fwdStart._thisptr.get()))
            )

    property quote:
        def __get__(self):
            cdef Handle[_qt.Quote] quote_handle = self._thisptr.get().quote()
            cdef shared_ptr[_qt.Quote] quote_ptr = shared_ptr[_qt.Quote](quote_handle.currentLink())
            value = quote_ptr.get().value()
            return value

cdef class FraRateHelper(RelativeDateRateHelper):
    """ Rate helper for bootstrapping over %FRA rates. """

    def __init__(self, Quote rate, Natural months_to_start,
            Natural months_to_end, Natural fixing_days, Calendar calendar,
            BusinessDayConvention convention, end_of_month,
            DayCounter day_counter):

        cdef Handle[_qt.Quote] rate_handle = Handle[_qt.Quote](deref(rate._thisptr))

        self._thisptr = new shared_ptr[_rh.RelativeDateRateHelper](
            new _rh.FraRateHelper(
                rate_handle,
                months_to_start,
                months_to_end,
                fixing_days,
                deref(calendar._thisptr),
                <_rh.BusinessDayConvention> convention,
                end_of_month,
                deref(day_counter._thisptr),
            )
        )

    property quote:
        def __get__(self):
            cdef Handle[_qt.Quote] quote_handle = self._thisptr.get().quote()
            cdef shared_ptr[_qt.Quote] quote_ptr = shared_ptr[_qt.Quote](quote_handle.currentLink())
            value = quote_ptr.get().value()
            return value

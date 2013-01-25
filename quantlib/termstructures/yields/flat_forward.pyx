"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'
from cython.operator cimport dereference as deref

from quantlib.time._period cimport Frequency
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Date, date_from_qldate

from quantlib.compounding import Continuous
from quantlib.time.date import Annual

cimport _flat_forward as ffwd
cimport quantlib._quote as _qt
from quantlib.quotes cimport Quote
from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure


cdef class FlatForward(YieldTermStructure):
    """ Flat intereste-rate curve """


    def __init__(self, Date reference_date=None, forward=None, DayCounter daycounter=None,
                 int settlement_days=0, Calendar calendar=None, compounding=Continuous,
                 frequency=Annual):

        self.relinkable = False

        #local cdef's
        cdef ffwd.Handle[_qt.Quote] quote_handle
        cdef ffwd.Date _reference_date

        if reference_date is not None:
            if isinstance(forward, Quote):
                quote_handle = ffwd.Handle[_qt.Quote](deref( (<Quote>forward)._thisptr))

                self._thisptr = new shared_ptr[ffwd.YieldTermStructure](
                    new ffwd.FlatForward(
                        deref(reference_date._thisptr.get()),
                        quote_handle,
                        deref(daycounter._thisptr),
                        <ffwd.Compounding>compounding,
                        <Frequency>frequency
                    )
                )
            else:
                self._thisptr = new shared_ptr[ffwd.YieldTermStructure](
                    new ffwd.FlatForward(
                        deref(reference_date._thisptr.get()),
                        <ffwd.Rate>forward,
                        deref(daycounter._thisptr),
                        <ffwd.Compounding>compounding,
                        <Frequency>frequency
                    )
                )
        elif settlement_days is not None and \
            calendar is not None:

            if isinstance(forward, Quote):
                quote_handle = ffwd.Handle[_qt.Quote](deref( (<Quote>forward)._thisptr))

                self._thisptr = new shared_ptr[ffwd.YieldTermStructure](
                    new ffwd.FlatForward(
                        <ffwd.Natural>settlement_days,
                        deref(calendar._thisptr),
                        quote_handle,
                        deref(daycounter._thisptr),
                        <ffwd.Compounding>compounding,
                        <Frequency>frequency
                    )
                )
            else:
                self._thisptr = new shared_ptr[ffwd.YieldTermStructure](
                    new ffwd.FlatForward(
                        <ffwd.Natural>settlement_days,
                        deref(calendar._thisptr),
                        <Real>forward,
                        deref(daycounter._thisptr),
                        <ffwd.Compounding>compounding,
                        <Frequency>frequency
                    )
                )
        elif settlement_days is not None and \
             calendar is not None:

            self._thisptr = new shared_ptr[ffwd.YieldTermStructure](
                new ffwd.FlatForward(
                    <ffwd.Natural>settlement_days,
                    deref(calendar._thisptr),
                    <ffwd.Rate>forward,
                    deref(daycounter._thisptr),
                    <ffwd.Compounding>compounding,
                    <Frequency>frequency
                )
            )
        else:
            raise ValueError('Invalid constructor')




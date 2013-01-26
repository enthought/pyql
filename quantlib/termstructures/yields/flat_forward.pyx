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
    """ Flat intereste-rate curve

    Parameters
    ----------

    refererence_date: quantlib.time.date.Date or None
        Reference date used by the curve. If None, the user must provide the
        settlement days.
    forward: quantlib.quote.Quote or float
        The forward value used by the curve.
    daycounter: quantlib.time.daycounter.DayCounter
        The day counter used by the curve.
    settlement_days: int
        The settlement days used by this curve. If a reference date is given,
        this parameter is not used.
    calendar: quantlib.time.calendar.Calendar
        The calendar used by the curve if created with the settlement days.
    compounding: int (default: Continuous)
        The type of compounding used by this curve.
    frequency: int (default: Annual)
        The frequency used by this curve.
    """


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
        else:
            raise ValueError('Invalid constructor')




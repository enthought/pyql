# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.


from quantlib.types cimport Natural, Rate
from cython.operator cimport dereference as deref

from quantlib.time.frequency cimport Frequency, Annual
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Date, date_from_qldate

from quantlib.compounding cimport Compounding

from . cimport _flat_forward as ffwd
from quantlib.quote cimport Quote


cdef class FlatForward(YieldTermStructure):
    """Flat interest-rate curve.

    This class creates a flat forward rate term structure.

    Parameters
    ----------
    reference_date : :class:`~quantlib.time.date.Date`, optional
        The reference date for the curve.
    forward : :class:`~quantlib.quote.Quote` or float
        The forward rate.
    daycounter : :class:`~quantlib.time.daycounter.DayCounter`
        The day counter for the curve.
    settlement_days : int, optional
        The number of settlement days, used if `reference_date` is not provided.
    calendar : :class:`~quantlib.time.calendar.Calendar`, optional
        The calendar for settlement days, used if `reference_date` is not provided.
    compounding : :class:`~quantlib.compounding.Compounding`, optional
        The compounding convention. Defaults to `Continuous`.
    frequency : :class:`~quantlib.time.frequency.Frequency`, optional
        The compounding frequency. Defaults to `Annual`.
    """

    def __init__(self, Date reference_date=None, forward=None,
                 DayCounter daycounter=None,
                 Natural settlement_days=0, Calendar calendar=None,
                 Compounding compounding=Compounding.Continuous,
                 Frequency frequency=Annual):

        if forward is None:
            raise ValueError('forward must be provided')

        if daycounter is None:
            raise ValueError('daycounter must be provided')

        if reference_date is not None:
            if isinstance(forward, Quote):
                self._thisptr.reset(
                    new ffwd.FlatForward(
                        reference_date._thisptr,
                        (<Quote>forward).handle(),
                        deref(daycounter._thisptr),
                        compounding,
                        frequency
                    )
                )
            else:
                self._thisptr.reset(
                    new ffwd.FlatForward(
                        reference_date._thisptr,
                        <Rate>forward,
                        deref(daycounter._thisptr),
                        compounding,
                        frequency
                    )
                )
        elif settlement_days is not None and \
            calendar is not None:

            if isinstance(forward, Quote):
                self._thisptr.reset(
                    new ffwd.FlatForward(
                        settlement_days,
                        calendar._thisptr,
                        (<Quote>forward).handle(),
                        deref(daycounter._thisptr),
                        compounding,
                        frequency
                    )
                )
            else:
                self._thisptr.reset(
                    new ffwd.FlatForward(
                        settlement_days,
                        calendar._thisptr,
                        <Rate>forward,
                        deref(daycounter._thisptr),
                        compounding,
                        frequency
                    )
                )
        else:
            raise ValueError('Invalid constructor')

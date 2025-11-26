# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

# Cython standard cimports
from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.vector cimport vector

# Cython QuantLib header cimports
cimport quantlib.time._calendar as _calendar
cimport quantlib.time._date as _date
cimport quantlib.time.date as date
cimport quantlib.time._period as _period
from quantlib.time.businessdayconvention cimport Following

cdef class Calendar:
    '''This class provides methods for determining whether a date is a
    business day or a holiday for a given market, and for
    incrementing/decrementing a date of a given number of business days.

    A calendar should be defined for specific exchange holiday schedule
    or for general country holiday schedule. Legacy city holiday schedule
    calendars will be moved to the exchange/country convention.
    '''

    @property
    def name(self):
        """name of the calendar"""
        return self._thisptr.name().decode('utf-8')

    def __str__(self):
        return self.name

    def is_holiday(self, date.Date test_date not None):
        """Returns `True` if the date is a holiday for the given market.

        Parameters
        ----------
        test_date : :class:`~quantlib.time.date.Date`
            The date to check.
        """
        return self._thisptr.isHoliday(test_date._thisptr)

    def is_weekend(self,  int week_day):
        """Returns `True` if the weekday is part of the weekend for the given market.

        Parameters
        ----------
        week_day : int
            The weekday to check (e.g., `quantlib.time.date.Monday`).
        """
        return self._thisptr.isWeekend(<_date.Weekday>week_day)

    def is_business_day(self, date.Date test_date not None):
        """Returns `True` if the date is a business day for the given market.

        Parameters
        ----------
        test_date : :class:`~quantlib.time.date.Date`
            The date to check.
        """
        return self._thisptr.isBusinessDay(test_date._thisptr)

    def is_end_of_month(self, date.Date test_date not None):
        """Returns `True` if the date is the last business day of the month in the given market.

        Parameters
        ----------
        test_date : :class:`~quantlib.time.date.Date`
            The date to check.
        """
        return self._thisptr.isEndOfMonth(test_date._thisptr)

    def business_days_between(self, date.Date date1 not None,
                              date.Date date2 not None,
                              include_first=True, include_last=False):
        """Returns the number of business days between two dates.

        Parameters
        ----------
        date1 : :class:`~quantlib.time.date.Date`
            The start date.
        date2 : :class:`~quantlib.time.date.Date`
            The end date.
        include_first : bool, optional
            Whether to include the start date in the calculation.
        include_last : bool, optional
            Whether to include the end date in the calculation.
        """
        return self._thisptr.businessDaysBetween(
            date1._thisptr,
            date2._thisptr,
            include_first,
            include_last
        )

    def end_of_month(self, date.Date current_date not None):
        """Returns the last business day of the month to which the given date belongs.

        Parameters
        ----------
        current_date : :class:`~quantlib.time.date.Date`
            The date to check.
        """
        cdef _date.Date eom_date = self._thisptr.endOfMonth(current_date._thisptr)
        return date.date_from_qldate(eom_date)

    def add_holiday(self, date.Date holiday not None):
        """Adds a date to the set of holidays for the given calendar.

        Parameters
        ----------
        holiday : :class:`~quantlib.time.date.Date`
            The holiday to add.
        """
        self._thisptr.addHoliday(holiday._thisptr)

    def remove_holiday(self, date.Date holiday not None):
        """Removes a date from the set of holidays for the given calendar.

        Parameters
        ----------
        holiday : :class:`~quantlib.time.date.Date`
            The holiday to remove.
        """
        self._thisptr.removeHoliday(holiday._thisptr)

    def adjust(self, date.Date given_date not None, int convention=Following):
        """Adjusts a non-business day to the appropriate near business day
        with respect to the given convention.

        Parameters
        ----------
        given_date : :class:`~quantlib.time.date.Date`
            The date to adjust.
        convention : int, optional
            The business day convention to use.
        """
        cdef _date.Date adjusted_date = self._thisptr.adjust(
                given_date._thisptr,
                <_calendar.BusinessDayConvention> convention)

        return date.date_from_qldate(adjusted_date)

    def advance(self, date.Date given_date not None, int step=0, int units=-1,
                date.Period period=None, int convention=Following,
                end_of_month=False):
        """Advances the given date by the given number of business days or period.

        Parameters
        ----------
        given_date : :class:`~quantlib.time.date.Date`
            The date to advance.
        step : int, optional
            The number of steps to advance.
        units : int, optional
            The time unit for the step.
        period : :class:`~quantlib.time.date.Period`, optional
            The period to advance the date by.
        convention : int, optional
            The business day convention to use.
        end_of_month : bool, optional
            Whether to preserve the end-of-month status.
        """
        cdef _date.Date advanced_date

        # fixme: add better checking on inputs
        if period is None and units > -1:
            advanced_date = self._thisptr.advance(given_date._thisptr,
                    step, <_period.TimeUnit>units,
                    <_calendar.BusinessDayConvention>convention, end_of_month)
        elif period is not None:
            advanced_date = self._thisptr.advance(given_date._thisptr,
                    deref(period._thisptr),
                    <_calendar.BusinessDayConvention>convention, end_of_month)
        else:
            raise ValueError(
                'You must at least provide a step and unit or a Period!'
            )

        return date.date_from_qldate(advanced_date)

    def __richcmp__(Calendar self not None, Calendar cal not None, int op):
        if op == 0:
            op_str = '<'
        elif op == 4:
            op_str = '>'
        elif op == 1:
            op_str = '<='
        elif op == 5:
            op_str = '>='
        elif op == 2:
            return self._thisptr == cal._thisptr
        elif op == 3:
            return self._thisptr != cal._thisptr
        raise TypeError(op_str + " not supported between instances of 'Calendar' and 'Calendar'")

    def holiday_list(self, date.Date from_date not None,
                     date.Date to_date not None, bool include_weekends=False):
        """Returns a list of holidays between two dates.

        Parameters
        ----------
        from_date : :class:`~quantlib.time.date.Date`
            The start date.
        to_date : :class:`~quantlib.time.date.Date`
            The end date.
        include_weekends : bool, optional
            Whether to include weekends in the list of holidays.
        """
        cdef vector[_date.Date] dates = self._thisptr.holidayList(
            from_date._thisptr,
            to_date._thisptr,
            include_weekends
        )
        cdef _date.Date d
        cdef list l = []
        for d in dates:
            l.append(date.date_from_qldate(d))
        return l

    def business_day_list(self, date.Date from_date not None,
                          date.Date to_date not None):
        """Returns a list of business days between two dates.

        Parameters
        ----------
        from_date : :class:`~quantlib.time.date.Date`
            The start date.
        to_date : :class:`~quantlib.time.date.Date`
            The end date.
        """
        cdef vector[_date.Date] dates = self._thisptr.businessDayList(
            from_date._thisptr,
            to_date._thisptr,
        )
        cdef _date.Date d
        cdef list l = []
        for d in dates:
            l.append(date.date_from_qldate(d))
        return l

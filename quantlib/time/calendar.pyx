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
from quantlib.time._businessdayconvention cimport Following

cdef class Calendar:
    '''This class provides methods for determining whether a date is a
    business day or a holiday for a given market, and for
    incrementing/decrementing a date of a given number of business days.

    A calendar should be defined for specific exchange holiday schedule
    or for general country holiday schedule. Legacy city holiday schedule
    calendars will be moved to the exchange/country convention.
    '''

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __cinit__(self):
        self._thisptr = new _calendar.Calendar()

    property name:
        def __get__(self):
            return self._thisptr.name().decode('utf-8')

    def __str__(self):
        return self.name

    def is_holiday(self, date.Date test_date):
        '''Returns true iff the weekday is part of the
        weekend for the given market.
        '''
        return self._thisptr.isHoliday(deref(test_date._thisptr))

    def is_weekend(self,  int week_day):
        '''Returns true iff the date is last business day for the
        month in given market.
        '''
        return self._thisptr.isWeekend(<_date.Weekday>week_day)

    def is_business_day(self, date.Date test_date):
        '''Returns true iff the date is a business day for the
        given market.
        '''
        return self._thisptr.isBusinessDay(deref(test_date._thisptr))

    def is_end_of_month(self, date.Date test_date):
        '''Is this date the last business day of the month to which the given
        date belongs
        '''
        return self._thisptr.isBusinessDay(deref(test_date._thisptr))

    def business_days_between(self, date.Date date1, date.Date date2,
            include_first=True, include_last=False):
        """ Returns the number of business days between date1 and date2. """

        return self._thisptr.businessDaysBetween(
            deref((<date.Date>date1)._thisptr),
            deref((<date.Date>date2)._thisptr),
            include_first,
            include_last
        )

    def end_of_month(self, date.Date current_date):
        """ Returns the ending date for the month that contains the given
        date.

        """

        cdef _date.Date eom_date = self._thisptr.endOfMonth(deref(current_date._thisptr))

        return date.date_from_qldate(eom_date)

    def add_holiday(self, date.Date holiday):
        '''Adds a date to the set of holidays for the given calendar. '''
        self._thisptr.addHoliday(deref(holiday._thisptr))

    def remove_holiday(self, date.Date holiday):
        '''Removes a date from the set of holidays for the given calendar.'''
        self._thisptr.removeHoliday(deref(holiday._thisptr))

    def adjust(self, date.Date given_date, int convention=Following):
        '''Adjusts a non-business day to the appropriate near business day
            with respect to the given convention.
        '''
        cdef _date.Date adjusted_date = self._thisptr.adjust(
                deref(given_date._thisptr),
                <_calendar.BusinessDayConvention> convention)

        return date.date_from_qldate(adjusted_date)

    def advance(self, date.Date given_date, int step=0, int units=-1,
               date.Period period=None, int convention=Following,
               end_of_month=False):
        '''Advances the given date of the given number of business days,
        or period and returns the result.

        You must provide either a step and unit or a Period.

        '''
        cdef _date.Date advanced_date

        # fixme: add better checking on inputs
        if period is None and units > -1:
            advanced_date = self._thisptr.advance(deref(given_date._thisptr),
                    step, <_period.TimeUnit>units,
                    <_calendar.BusinessDayConvention>convention, end_of_month)
        elif period is not None:
            advanced_date = self._thisptr.advance(deref(given_date._thisptr),
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
            return deref(self._thisptr) == deref(cal._thisptr)
        elif op == 3:
            return deref(self._thisptr) != deref(cal._thisptr)
        raise TypeError(op_str + " not supported between instances of 'Calendar' and 'Calendar'")


def holiday_list(Calendar calendar, date.Date from_date, date.Date to_date,
        bool include_weekends=False):
    '''Returns the holidays between two dates. '''

    cdef vector[_date.Date] dates = _calendar.Calendar_holidayList(
        deref(calendar._thisptr),
        deref(from_date._thisptr),
        deref(to_date._thisptr),
        include_weekends
    )
    cdef _date.Date d
    cdef list l = []
    for d in dates:
        l.append(date.date_from_qldate(d))
    return l

# Copyright (C) 2013, Enthought Inc
# Copyright (C) 2013, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

include 'types.pxi'

from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.string cimport string

cimport quantlib.time._calendar as _calendar
cimport quantlib.time._date as _date
from quantlib.time_series cimport TimeSeries
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date, date_from_qldate

cdef class Index:

    def __init__(self):
        raise ValueError('Cannot instantiate Index')

    property name:
       def __get__(self):
           return self._thisptr.get().name().decode('utf-8')

    property fixing_calendar:
        def __get__(self):
            cdef Calendar cal = Calendar.__new__(Calendar)
            cal._thisptr = new _calendar.Calendar(self._thisptr.get().fixingCalendar())
            return cal

    @property
    def time_series(self):
        cdef TimeSeries ts = TimeSeries.__new__(TimeSeries)
        ts._thisptr = self._thisptr.get().timeSeries()
        return ts

    def is_valid_fixing_date(self, Date fixingDate not None):
        return self._thisptr.get().isValidFixingDate(
            deref(fixingDate._thisptr))

    def fixing(self, Date fixingDate not None, bool forecastTodaysFixing=False):
        return self._thisptr.get().fixing(
            deref(fixingDate._thisptr), forecastTodaysFixing)

    def add_fixing(self, Date fixingDate not None, Real fixing, bool forceOverwrite=False):
        self._thisptr.get().addFixing(
            deref(fixingDate._thisptr), fixing, forceOverwrite
        )

    def clear_fixings(self):
        self._thisptr.get().clearFixings()

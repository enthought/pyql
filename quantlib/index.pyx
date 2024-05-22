# Copyright (C) 2013, Enthought Inc
# Copyright (C) 2013, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.
"""Abstract base class for indices"""
include 'types.pxi'

from cpython.datetime cimport PyDate_Check, date_year, date_month, date_day, import_datetime
from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.string cimport string

cimport quantlib.time._calendar as _calendar
from quantlib.time_series cimport TimeSeries
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date, date_from_qldate
from quantlib.time._date cimport Date as QlDate, Month

import_datetime()

cdef class Index:
    """Abstract base class for indices

    .. warning::

      this class performs no check that the
      provided/requested fixings are for dates in the past,
      i.e. for dates less than or equal to the evaluation
      date. It is up to the client code to take care of
      possible inconsistencies due to "seeing in the
      future"
    """

    def __init__(self):
        raise ValueError('Cannot instantiate Index')

    property name:
       """the name of the index

       .. warning::

         This method is used for output and comparison
         between indexes.
       """
       def __get__(self):
           return self._thisptr.get().name().decode('utf-8')

    property fixing_calendar:
        """the calendar defining valid fixing dates"""
        def __get__(self):
            cdef Calendar cal = Calendar.__new__(Calendar)
            cal._thisptr = self._thisptr.get().fixingCalendar()
            return cal

    @property
    def time_series(self):
        """the fixing TimeSeries"""
        cdef TimeSeries ts = TimeSeries.__new__(TimeSeries)
        ts._thisptr = self._thisptr.get().timeSeries()
        return ts

    def is_valid_fixing_date(self, Date fixing_date not None):
        return self._thisptr.get().isValidFixingDate(
            fixing_date._thisptr)

    def fixing(self, Date fixingDate not None, bool forecast_todays_fixing=False):
        return self._thisptr.get().fixing(
            fixingDate._thisptr, forecast_todays_fixing)

    def add_fixing(self, Date fixingDate not None, Real fixing, bool force_overwrite=False):
        self._thisptr.get().addFixing(
            fixingDate._thisptr, fixing, force_overwrite
        )

    def add_fixings(self, list dates, list values, bool force_overwrite=False):
        cdef:
            vector[QlDate] qldates
            vector[Real] qlvalues
            Real v

        for d, v in zip(dates, values):
            if PyDate_Check(d):
                qldates.push_back(QlDate(date_day(d), <Month>date_month(d), date_year(d)))
            elif isinstance(d, Date):
                qldates.push_back((<Date>d)._thisptr)
            else:
                raise TypeError
            qlvalues.push_back(<Real?>v)
        self._thisptr.get().addFixings(qldates.begin(), qldates.end(), qlvalues.begin(), force_overwrite)

    def clear_fixings(self):
        self._thisptr.get().clearFixings()

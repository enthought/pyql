"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include 'types.pxi'

from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector

from quantlib.time._calendar cimport Calendar
from quantlib.time._date cimport Date

cdef extern from "ql/timeseries.hpp" namespace "QuantLib":
    cdef cppclass TimeSeries[T]:
        TimeSeries()
        vector[T] values()
        vector[Date] dates()
        Size size()

cdef extern from 'ql/index.hpp' namespace 'QuantLib':

    cdef cppclass Index:
        Index()
        string name()
        Calendar& fixingCalendar()
        bool isValidFixingDate(Date& fixingDate)
        Real fixing(Date& fixingDate, bool forecastTodaysFixing)
        void addFixing(Date& fixingDate, Real fixing, bool forceOverwrite) except +
        TimeSeries[Real] timeSeries()

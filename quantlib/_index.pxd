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

from quantlib._observable cimport Observable
from quantlib._time_series cimport TimeSeries
from quantlib.time._calendar cimport Calendar
from quantlib.time._date cimport Date


cdef extern from 'ql/index.hpp' namespace 'QuantLib':

    cdef cppclass Index(Observable):
        string name()
        Calendar& fixingCalendar()
        bool isValidFixingDate(Date& fixingDate)
        Rate fixing(Date& fixingDate, bool forecastTodaysFixing) except +
        void addFixing(Date& fixingDate, Real fixing, bool forceOverwrite) except +
        TimeSeries[Real] timeSeries()
        void clearFixings()

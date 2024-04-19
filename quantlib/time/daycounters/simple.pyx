"""This module contains "simple" Daycounter classes, i.e. which do not depend on
a convention"""

from . cimport _simple
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.calendars.target cimport TARGET
from quantlib.time.calendar cimport Calendar
from libcpp cimport bool

cdef class Actual365Fixed(DayCounter):

    def __cinit__(self):
        self._thisptr = new _simple.Actual365Fixed()


cdef class Actual360(DayCounter):

    def __cinit__(self, bool include_last_day = False):
        self._thisptr = new _simple.Actual360(include_last_day)


cdef class Business252(DayCounter):

    def __cinit__(self, Calendar calendar=TARGET()):
        self._thisptr = new _simple.Business252(calendar._thisptr)


cdef class OneDayCounter(DayCounter):

    def __cinit__(self):
        self._thisptr = new _simple.OneDayCounter()


cdef class SimpleDayCounter(DayCounter):

    def __cinit__(self):
        self._thisptr = new _simple.SimpleDayCounter()

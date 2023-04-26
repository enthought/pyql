"""This module contains "simple" Daycounter classes, i.e. which do not depend on
a convention"""

from cython.operator cimport dereference as deref

cimport quantlib.time._daycounter as _daycounter
from . cimport _simple
from quantlib.time.daycounter cimport DayCounter
cimport quantlib.time.calendars._target as _tg
cimport quantlib.time._calendar as _calendar
from quantlib.time.calendar cimport Calendar
from libcpp cimport bool

cdef class Actual365Fixed(DayCounter):

    def __cinit__(self, *args):
        self._thisptr = <_daycounter.DayCounter*> new _simple.Actual365Fixed()


cdef class Actual360(DayCounter):

    def __cinit__(self, bool include_last_day = False):
        self._thisptr = <_daycounter.DayCounter*> new _simple.Actual360(include_last_day)


cdef class Business252(DayCounter):

    def __cinit__(self, *args, calendar=None):
        cdef _calendar.Calendar cl
        if calendar is None:
           cl = _tg.TARGET()
        else:
           cl = (<Calendar>calendar)._thisptr
        self._thisptr = <_daycounter.DayCounter*> new _simple.Business252(cl)


cdef class OneDayCounter(DayCounter):

    def __cinit__(self, *args):
        self._thisptr = <_daycounter.DayCounter*> new _simple.OneDayCounter()


cdef class SimpleDayCounter(DayCounter):

    def __cinit__(self, *args):
        self._thisptr = <_daycounter.DayCounter*> new _simple.SimpleDayCounter()

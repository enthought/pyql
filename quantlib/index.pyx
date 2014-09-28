"""
 Copyright (C) 2013, Enthought Inc
 Copyright (C) 2013, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include 'types.pxi'

from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.string cimport string

cimport quantlib.time._calendar as _calendar

from quantlib.time.date cimport Date
from quantlib.time.calendar cimport Calendar
from quantlib.util.compat cimport utf8_char_array_to_py_compat_str

cdef class Index:

    def __cinit__(self):
        pass

    def __init__(self):
        raise ValueError('Cannot instantiate Index')

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    property name:
       def __get__(self):
           return utf8_char_array_to_py_compat_str(self._thisptr.get().name().c_str())

    property fixing_calendar:
        def __get__(self):
            cdef _calendar.Calendar fc
            fc = self._thisptr.get().fixingCalendar()
            cdef string _calendar_name = fc.name()
            code = Calendar._inv_code[
                utf8_char_array_to_py_compat_str(_calendar_name.c_str())
            ]
            return Calendar.from_name(code)

    def is_valid_fixing_date(self, Date fixingDate):
        return self._thisptr.get().isValidFixingDate(
            deref(fixingDate._thisptr.get()))

    def fixing(self, Date fixingDate, bool forecastTodaysFixing):
        return self._thisptr.get().fixing(
            deref(fixingDate._thisptr.get()), forecastTodaysFixing)

    def add_fixing(self, Date fixingDate, Real fixing, bool forceOverwrite):
        self._thisptr.get().addFixing(
            deref(fixingDate._thisptr.get()), fixing, forceOverwrite)


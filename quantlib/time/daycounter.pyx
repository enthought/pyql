# coding: utf-8
from __future__ cimport unicode_literals

from cython.operator cimport dereference as deref
from libcpp.string cimport string

cimport _daycounter
cimport _date
cimport _calendar

from date cimport Date
from calendar cimport Calendar
from quantlib.util.compat cimport py_string_from_utf8_array
from quantlib.time.daycounters.actual_actual cimport from_name as aa_from_name
from quantlib.time.daycounters.thirty360 cimport from_name as th_from_name

from quantlib.util.compat cimport _ustring

cdef class DayCounter:
    '''This class provides methods for determining the length of a time
        period according to given market convention, both as a number
        of days and as a year fraction.

    '''

    def __cinit__(self, *args):
        pass

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def name(self):
        cdef string _name = self._thisptr.name()
        return py_string_from_utf8_array(_name.c_str())

    def year_fraction(self, Date date1, Date date2, Date ref_start=None,
            Date ref_end=None):
        ''' Returns the period between two dates as a fraction of year.'''
        cdef _date.Date* d1 = date1._thisptr.get()
        cdef _date.Date* d2 = date2._thisptr.get()
        cdef _date.Date* refStart
        cdef _date.Date* refEnd
        if ref_start is None:
            refStart = new _date.Date()
        else:
            refStart = ref_start._thisptr.get()
        if ref_end is None:
            refEnd = new _date.Date()
        else:
            refEnd = ref_end._thisptr.get()

        return self._thisptr.yearFraction(
            deref(d1), deref(d2), deref(refStart), deref(refEnd)
        )

    def day_count(self, Date date1, Date date2):
        ''' Returns the number of days between two dates.'''
        cdef _date.Date* d1 = date1._thisptr.get()
        cdef _date.Date* d2 = date2._thisptr.get()
        return self._thisptr.dayCount(deref(d1), deref(d2))

    def __richcmp__(self, other_counter, val):

        if not isinstance(other_counter, DayCounter):
            return NotImplemented

        # if we compare two day counter for equality, the underlying
        # QuantLib counter must be of the same type. Testing if names are
        # the same gives us a valid answer
        a = self.name()
        b = other_counter.name()

        # we only support testing for equality and inequality
        if val == 2:
            return a == b
        elif val == 3:
            return a != b
        else:
            return False

    @classmethod
    def from_name(cls, name):
        cdef DayCounter cnt = cls()
        cdef _daycounter.DayCounter* new_counter
        name, convention = _get_daycounter_type_from_name(name)
        new_counter = daycounter_from_name(name, convention)

        if new_counter == NULL:
            raise ValueError('Unknown day counter type: {}'.format(name))
        else:
            cnt._thisptr = new_counter
            return cnt

def _get_daycounter_type_from_name(name):
    """ Returns a tuple (counter type, convention) from the DayCounter name. """
    DAYCOUNTER_NAME_PATTERN = '(.*) \((.*)\)'
    import re
    u_name = _ustring(name)
    match = re.match(DAYCOUNTER_NAME_PATTERN, u_name)

    if match is not None:
        return match.groups()
    else:
        return (u_name, None)


cdef _daycounter.DayCounter* daycounter_from_name(name, convention):
    """ Returns a new DayCounter pointer.

    The QuantLib DayCounter don't have a copy constructor or any other easy
    way to get copy of a given DayCounter. """

    name_u = name.upper()

    cdef _daycounter.DayCounter* cnt = NULL
    if name_u in ['ACTUAL360', 'ACTUAL/360', 'ACT/360']:
        cnt = new _daycounter.Actual360()
    elif name_u in ['ACTUAL365FIXED', 'ACTUAL/365', 'ACT/365']:
        cnt = new _daycounter.Actual365Fixed()
    elif name_u == 'BUSINESS252':
        raise ValueError(
            'Business252 from name is not supported. Requires a calendar'
        )
    elif name_u in ['1/1', 'ONEDAYCOUNTER']:
        cnt = new _daycounter.OneDayCounter()
    elif name_u == 'SIMPLEDAYCOUNTER':
        cnt = new _daycounter.SimpleDayCounter()
    elif name_u.startswith('ACTUAL/ACTUAL') or name_u.startswith('ACT/ACT') :
        cnt = aa_from_name(convention)
    elif name_u.startswith('30/360'):
        if convention is None:
            convention = 'BONDBASIS'
        cnt = th_from_name(convention)
    return cnt


cdef class Actual360(DayCounter):

    def __cinit__(self, *args):
        self._thisptr = <_daycounter.DayCounter*> new _daycounter.Actual360()


cdef class Actual365Fixed(DayCounter):

    def __cinit__(self, *args):
        self._thisptr = <_daycounter.DayCounter*> new _daycounter.Actual365Fixed()


cdef class Business252(DayCounter):

    def __cinit__(self, *args, calendar=None):
        cdef _calendar.Calendar* cl
        if calendar is None:
           cl = <_calendar.Calendar*> new _calendar.TARGET()
        else:
           cl = (<Calendar>calendar)._thisptr
        self._thisptr = <_daycounter.DayCounter*> new _daycounter.Business252(deref(cl))

cdef class OneDayCounter(DayCounter):

    def __cinit__(self, *args):
        self._thisptr = <_daycounter.DayCounter*> new _daycounter.OneDayCounter()

cdef class SimpleDayCounter(DayCounter):

    def __cinit__(self, *args):
        self._thisptr = <_daycounter.DayCounter*> new _daycounter.SimpleDayCounter()


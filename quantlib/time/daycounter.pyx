from cython.operator cimport dereference as deref
cimport _daycounter
cimport _date
cimport _calendar
from date cimport Date
from calendar cimport Calendar

cdef class DayCounter:
    '''This class provides methods for determining the length of a time
        period according to given market convention, both as a number
        of days and as a year fraction.
    '''

    def __cinit__(self, *args):
        pass

    def name(self):
        return self._thisptr.name().c_str()

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


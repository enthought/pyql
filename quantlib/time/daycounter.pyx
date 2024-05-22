from cython.operator cimport dereference as deref

from . cimport _daycounter
from . cimport _date

from .date cimport Date

cdef class DayCounter:
    '''This class provides methods for determining the length of a time
        period according to given market convention, both as a number
        of days and as a year fraction.

    '''

    def __cinit__(self, *args):
        self._thisptr = new _daycounter.DayCounter()

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    @property
    def name(self):
        return self._thisptr.name().decode('utf-8')

    def __str__(self):
        return self.name

    def __repr__(self):
        return "DayCounter('{0}')".format(self.name)

    def year_fraction(self, Date date1 not None, Date date2 not None,
            Date ref_start=Date(), Date ref_end=Date()):
        ''' Returns the period between two dates as a fraction of year.'''
        return self._thisptr.yearFraction(
            date1._thisptr, date2._thisptr,
            ref_start._thisptr, ref_end._thisptr
        )

    def day_count(self, Date date1 not None, Date date2 not None):
        ''' Returns the number of days between two dates.'''
        return self._thisptr.dayCount(date1._thisptr, date2._thisptr)

    def __richcmp__(self, other_counter, int val):

        if not isinstance(other_counter, DayCounter):
            return NotImplemented

        # we only support testing for equality and inequality
        if val == 2:
            return deref((<DayCounter>other_counter)._thisptr) == deref((<DayCounter>self)._thisptr)
        elif val == 3:
            return deref((<DayCounter>other_counter)._thisptr) != deref((<DayCounter>self)._thisptr)
        else:
            return False

    @classmethod
    def from_name(cls, name):
        name, convention = _get_daycounter_type_from_name(name)
        return daycounter_from_name(name, convention)

def _get_daycounter_type_from_name(name):
    """ Returns a tuple (counter type, convention) from the DayCounter name. """
    DAYCOUNTER_NAME_PATTERN = '(.*) \((.*)\)'
    import re
    match = re.match(DAYCOUNTER_NAME_PATTERN, name)

    if match is not None:
        return match.groups()
    else:
        return (name, None)


cdef DayCounter daycounter_from_name(str name, str convention):
    """ Returns a new DayCounter pointer.

    The QuantLib DayCounter don't have a copy constructor or any other easy
    way to get copy of a given DayCounter. """

    name_u = name.upper()
    from .daycounters.simple import Actual365Fixed, Actual360, OneDayCounter, SimpleDayCounter
    from .daycounters.actual_actual import ActualActual, Convention as aaConvention
    from .daycounters.thirty360 import Thirty360, Convention as thConvention
    if name_u in ['ACTUAL360', 'ACTUAL/360', 'ACT/360']:
        return Actual360(convention == "inc")
    elif name_u in ['ACTUAL365FIXED', 'ACTUAL/365', 'ACT/365']:
        return Actual365Fixed()
    elif name_u == 'BUSINESS252':
        raise ValueError(
            'Business252 from name is not supported. Requires a calendar'
        )
    elif name_u in ['1/1', 'ONEDAYCOUNTER']:
        return OneDayCounter()
    elif name_u == 'SIMPLEDAYCOUNTER':
        return SimpleDayCounter
    elif name.startswith('Actual/Actual') or name.startswith('ACT/ACT') :
        try:
            return ActualActual(aaConvention[convention])
        except KeyError as e:
            raise ValueError(str(e))
    elif name == "30/360" or name == "30E/360":
        if convention is None:
            convention = 'BondBasis'
        convention = convention.replace(" ", "")
        try:
            return Thirty360(thConvention[convention])
        except KeyError as e:
            raise ValueError(str(e))
    else:
        raise ValueError("Unkown day counter type: {}".format(name))

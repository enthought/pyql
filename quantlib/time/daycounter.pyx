from cython.operator cimport dereference as deref

cimport _daycounter
cimport _date

from date cimport Date
from quantlib.time.daycounters.actual_actual cimport from_name as aa_from_name
from quantlib.time.daycounters.thirty360 cimport from_name as th_from_name
cimport quantlib.time.daycounters._simple as _simple

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
            deref(date1._thisptr), deref(date2._thisptr),
            deref(ref_start._thisptr), deref(ref_end._thisptr)
        )

    def day_count(self, Date date1 not None, Date date2 not None):
        ''' Returns the number of days between two dates.'''
        return self._thisptr.dayCount(deref(date1._thisptr), deref(date2._thisptr))

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
        cdef DayCounter cnt = cls.__new__(cls)
        name, convention = _get_daycounter_type_from_name(name)
        cnt._thisptr = daycounter_from_name(name, convention)

        if cnt._thisptr == NULL:
            raise ValueError('Unknown day counter type: {}'.format(name))
        return cnt

def _get_daycounter_type_from_name(name):
    """ Returns a tuple (counter type, convention) from the DayCounter name. """
    DAYCOUNTER_NAME_PATTERN = '(.*) \((.*)\)'
    import re
    match = re.match(DAYCOUNTER_NAME_PATTERN, name)

    if match is not None:
        return match.groups()
    else:
        return (name, None)


cdef _daycounter.DayCounter* daycounter_from_name(basestring name, basestring convention):
    """ Returns a new DayCounter pointer.

    The QuantLib DayCounter don't have a copy constructor or any other easy
    way to get copy of a given DayCounter. """

    name_u = name.upper()

    cdef _daycounter.DayCounter* cnt = NULL
    if name_u in ['ACTUAL360', 'ACTUAL/360', 'ACT/360']:
        cnt = new _simple.Actual360()
    elif name_u in ['ACTUAL365FIXED', 'ACTUAL/365', 'ACT/365']:
        cnt = new _simple.Actual365Fixed()
    elif name_u == 'BUSINESS252':
        raise ValueError(
            'Business252 from name is not supported. Requires a calendar'
        )
    elif name_u in ['1/1', 'ONEDAYCOUNTER']:
        cnt = new _simple.OneDayCounter()
    elif name_u == 'SIMPLEDAYCOUNTER':
        cnt = new _simple.SimpleDayCounter()
    elif name.startswith('Actual/Actual') or name.startswith('ACT/ACT') :
        cnt = aa_from_name(convention)
    elif name.startswith('30/360'):
        if convention is None:
            convention = 'BONDBASIS'
        cnt = th_from_name(convention)
    return cnt

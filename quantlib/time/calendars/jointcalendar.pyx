from cython.operator cimport dereference as deref
cimport cython
cimport quantlib.time.calendars._jointcalendar as _jc
cimport quantlib.time._calendar as _cal
from quantlib.time.calendar cimport Calendar

cpdef enum JointCalendarRule:
    JOINHOLIDAYS = _jc.JoinHolidays
    JOINBUSINESSDAYS = _jc.JoinBusinessDays

cdef class JointCalendar(Calendar):
    '''
    Joint calendar
    Depending on the chosen rule, this calendar has a set of
    business days given by either the union or the intersection
    of the sets of business days of the given calendars.
    '''

    @cython.cpp_locals(True)
    def __cinit__(self, Calendar c1, Calendar c2, int jc = JOINHOLIDAYS):
        self._thisptr = _jc.JointCalendar(c1._thisptr,
                                          c2._thisptr,
                                          <_jc.JointCalendarRule> jc)

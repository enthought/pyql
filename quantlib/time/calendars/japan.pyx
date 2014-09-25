cimport quantlib.time._calendar as _calendar
cimport quantlib.time.calendars._japan as _jp
from quantlib.time.calendar cimport Calendar

cdef class Japan(Calendar):
    ''' Japan calendars.
   '''

    def __cinit__(self):

        self._thisptr = <_calendar.Calendar*> new \
            _jp.Japan()

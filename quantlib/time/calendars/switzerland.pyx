cimport quantlib.time._calendar as _calendar
cimport quantlib.time.calendars._switzerland as _sw
from quantlib.time.calendar cimport Calendar

cdef class Switzerland(Calendar):
    ''' Swiss calendars.
   '''

    def __cinit__(self):

        self._thisptr = <_calendar.Calendar*> new \
            _sw.Switzerland()

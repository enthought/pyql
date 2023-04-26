cimport quantlib.time.calendars._target as _tg
from quantlib.time.calendar cimport Calendar

cdef class TARGET(Calendar):
    '''TARGET calendar

    Holidays (see http://www.ecb.int):

     * Saturdays
     * Sundays
     * New Year's Day, January 1st
     * Good Friday (since 2000)
     * Easter Monday (since 2000)
     * Labour Day, May 1st (since 2000)
     * Christmas, December 25th
     * Day of Goodwill, December 26th (since 2000)
     * December 31st (1998, 1999, and 2001)
    '''

    def __cinit__(self):
        self._thisptr = _tg.TARGET()

cimport quantlib.time.calendars._weekends_only as _wo
from quantlib.time.calendar cimport Calendar


cdef class WeekendsOnly(Calendar):
    '''Calendar for reproducing SNAC computaions.

    This calendar has no bank holidays except for weekends (Saturdays and Sundays)
    as required by ISDA for calculating conventional CDS spreads.

    '''

    def __cinit__(self):
        self._thisptr = new _wo.WeekendsOnly()

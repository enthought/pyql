cimport quantlib.time.calendars._null_calendar as _nc
from quantlib.time.calendar cimport Calendar


cdef class NullCalendar(Calendar):
    '''Calendar for reproducing theoretical calculations.
    
    This calendar has no holidays. It ensures that dates at whole-month 
    distances have the same day of month.

    '''

    def __cinit__(self):
        self._thisptr = new _nc.NullCalendar()


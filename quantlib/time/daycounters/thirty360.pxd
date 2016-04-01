cimport quantlib.time._daycounter as _daycounter
from quantlib.time.daycounter cimport DayCounter


cdef class Thirty360(DayCounter):
    pass


cdef _daycounter.DayCounter* from_name(str convention)

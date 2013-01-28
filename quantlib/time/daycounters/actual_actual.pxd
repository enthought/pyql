cimport quantlib.time._daycounter as _daycounter
from quantlib.time.daycounter cimport DayCounter


cdef class ActualActual(DayCounter):
    pass


cdef _daycounter.DayCounter* from_name(str name, str convention)


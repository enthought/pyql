cimport quantlib.time._daycounter as _daycounter
from quantlib.time.daycounter cimport DayCounter


cdef class Actual365Fixed(DayCounter):
    pass

cdef class Actual360(DayCounter):
    pass

cdef class Business252(DayCounter):
    pass

cdef class OneDayCounter(DayCounter):
    pass

cdef class SimpleDayCounter(DayCounter):
    pass

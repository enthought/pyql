cimport quantlib.time._daycounter as _daycounter

cdef class DayCounter:

    cdef _daycounter.DayCounter* _thisptr

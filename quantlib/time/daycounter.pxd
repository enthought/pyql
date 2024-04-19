from . cimport _daycounter

cdef class DayCounter:

    cdef _daycounter.DayCounter* _thisptr

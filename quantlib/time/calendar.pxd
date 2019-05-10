cimport quantlib.time._calendar as _calendar

from libcpp.vector cimport vector

cdef class Calendar:
    cdef _calendar.Calendar* _thisptr

cdef class TARGET(Calendar):
    pass

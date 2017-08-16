cimport _calendar
cimport _date

from libcpp.vector cimport vector

cdef class Calendar:
    cdef _calendar.Calendar* _thisptr

cdef class TARGET(Calendar):
    pass

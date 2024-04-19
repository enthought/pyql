from . cimport _calendar

from libcpp.vector cimport vector

cdef class Calendar:
    cdef _calendar.Calendar _thisptr
